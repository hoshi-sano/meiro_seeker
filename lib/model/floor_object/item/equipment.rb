module MeiroSeeker
  # 装備品の基本となるクラス
  class Equipment < Item
    class << self
      def base_strength(value)
        @base_strength = value
      end

      def get_base_strength
        @base_strength || 0
      end

      def equipped_image_path(value)
        @equipped_image_path = value
        args = [@equipped_image_path,
                CHARACTER_PATTERN_NUM_X, CHARACTER_PATTERN_NUM_Y]
        @equipped_images = FileLoadProxy.load_image_tiles(*args)
      end

      def equipped_images
        @equipped_images
      end

      def extra_effect(*values)
        raise MustNotHappen, self unless (STATUSES & values) == values
        @extra_effects = values
      end

      def default_extra_effect
        @extra_effects || []
      end
    end

    EQUIPPED_SIGN = 'E'
    MAX_CALIBRATION = 99

    attr_reader   :base_strength, :equipped_image_path
    attr_accessor :equipped_by, :calibration

    def initialize
      super
      @equipped_by = nil
      @calibration = 0
      @base_strength = self.class.get_base_strength
      @extra_effect = self.class.default_extra_effect
    end

    # 補正値付きの名前の文字列を返す
    def name
      res = super()
      if !@calibration.zero?
        calib = ((@calibration > 0) ? '+' : '-') + (@calibration.abs.to_s)
        res += calib
      end
      res
    end

    # アイテムウインドウ内での表示名
    # 装備済みの場合は先頭に装備マークを付ける
    # TODO: その他の記号対応
    def display_name
      self.equipped? ? "#{EQUIPPED_SIGN}#{self.name}" : self.name
    end

    def equipment_type
      self.class::TYPE
    end

    def equipped_images
      self.class.equipped_images
    end

    # 大ダメージを与えることのできる敵種族を配列で返す
    def defeat
      res = []
      @extra_effect.each do |sym|
        if idx = sym.match(/_buster$/)
          res << sym[0...idx].to_sym # '_buster'を除去
        end
      end
      res
    end

    # 引数に指定した特殊能力を持つか否か
    def has_ability?(sym)
      @extra_effect.include?(sym)
    end

    # 引数に指定したステータス異常に対して体制を持っているか否か
    def anti?(sym)
      anti_sym = "anti_#{sym}".to_sym unless sym.match(/^anti_/)
      has_ability?(anti_sym)
    end

    # 誰かに装備されているか否か
    def equipped?
      !!@equipped_by
    end

    # 装備を外された場合に呼ばれる
    def removed!
      @equipped_by.remove_equipment(self.equipment_type)
      @equipped_by = nil
    end

    def item_menu_choices(scene)
      if self.equipped?
        choices = {MENU_WORDS[:remove] => lambda { self.remove_event(scene) }}
      else
        choices = {MENU_WORDS[:equip] => lambda { self.equip_event(scene) }}
      end
      rest = {
        MENU_WORDS[:throw] => lambda { ItemThrowEvent.create(scene, scene.player, self) },
        MENU_WORDS[:put]   => lambda { PutItemEvent.create(scene, self) },
        MENU_WORDS[:note]  => lambda { ShowItemNoteEvent.create(scene, self) },
      }
      choices.merge!(rest)
      choices
    end

    def underfoot_menu_choices(scene)
      {
        MENU_WORDS[:get]   => get_from_underfoot_proc(scene),
        MENU_WORDS[:throw] => lambda { ItemThrowEvent.create(scene, scene.player, self) },
        MENU_WORDS[:note]  => lambda { ShowItemNoteEvent.create(scene, self) },
      }
    end

    def equip_event(scene)
      EquipEvent.create(scene, self)
    end

    def remove_event(scene)
      RemoveEquipmentEvent.create(scene, self)
    end

    def calc_base_hit_damage
      0
    end

    # 投擲した場合のイベント
    def hit_event(scene, thrower, target)
      return Event.new { |e| e.finalize } if thrower.dead?
      with_death_check(scene, thrower, target) do |scene, thrower, target|
        e = super
        offence = (calc_base_hit_damage +
                   thrower.calc_level_calibration +
                   thrower.calc_power_calibration).round
        # TODO: 乱数を使う
        damage = [offence - target.defence, 1].max
        # プレーヤーへのダメージの場合、画面に表示する残りHPと被ダ
        # メージ演出をシンクロさせるため、ここではHPの計算を行わない
        target.hp -= damage if target.type != :player
        e.set_next(DamageEvent.create(scene, target, damage))
        msg = MessageManager.to_damage(damage)
        e.set_next(ShowMessageEvent.create(scene, msg))
        e
      end
    end
  end
end

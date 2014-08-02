module MyDungeonGame
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
      end

      def get_equipped_image_path
        @equipped_image_path
      end
    end

    EQUIPPED_SIGN = 'E'

    attr_reader   :base_strength, :equipped_image_path
    attr_accessor :equipped_by, :calibration

    def initialize
      super
      @equipped_by = nil
      @calibration = 0
      @base_strength = self.class.get_base_strength
      @equipped_image_path = self.class.get_equipped_image_path
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
      e = super
      offence = (calc_base_hit_damage +
                 thrower.calc_level_calibration +
                 thrower.calc_power_calibration).round
      # TODO: 乱数を使う
      damage = [offence - target.defence, 1].max
      target.hp -= damage
      e.set_next(DamageEvent.create(scene, target, damage))
      msg = MessageManager.to_damage(damage)
      e.set_next(ShowMessageEvent.create(scene, msg))

      # アイテムヒットによって対象のHPが0になった場合
      scene.instance_eval do
        if target.dead?
          thrower.kill(target)
          @floor.remove_character(target.x, target.y)
        end

        judge = Event.new do |e|
          # killメソッドによってthrowerの@eventsにpackしたイベントが登
          # 録されるため、それを直ちに実行すべく展開してcut_inする
          while event_packet = thrower.pop_event
            e.set_next_cut_in(event_packet.unpack(self))
          end
          e.finalize
        end
        e.set_next(judge)
      end

      e
    end
  end
end

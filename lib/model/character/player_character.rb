module MeiroSeeker
  class PlayerCharacter < Character
    type :player
    image_path PLAYER_IMAGE_PATH
    update_interval 10
    name "PLAYER"
    level 1
    hp 15
    power 8
    exp 0

    attr_reader   :weapon, :shield, :ring, :bullet,
                  :current_direction, :current_frame
    attr_accessor :floor, :stomach, :max_power, :max_stomach, :money, :items

    HUNGER_INTERVAL = 10
    HP_GAIN_MIN = 2
    HP_GAIN_AMPLITUDE = 5

    def initialize(floor)
      super(floor)
      @money = 0
      @self_healing_value = 0 # 自然治癒力
      @stomach = 100     # 満腹度
      @max_stomach = 100 # 最大満腹度
      @max_power = @power # 力の最大値
      @hunger_interval = HUNGER_INTERVAL
      @items = [] # 所持アイテムリスト
      @weapon = nil # 装備武器
      @shield = nil # 装備盾
      @ring   = nil # 装備指輪
      @bullet = nil # 装備弾丸
    end

    def name
      GeneralManager.player_name
    end

    def level_up
      @level += 1
      hp_diff = randomizer.rand(HP_GAIN_AMPLITUDE + 1) + HP_GAIN_MIN # 2..7
      @max_hp += hp_diff
      @hp += hp_diff
    end

    # 武器の強さ
    def weapon_strength
      @weapon ? @weapon.strength : 0
    end

    # 盾の強さ
    def shield_strength
      @shield ? @shield.strength : 0
    end

    def accuracy
      PLAYER_ATTACK_ACCURACY
    end

    # 毎ターンの自然治癒
    def self_healing
      # HPの回復
      @self_healing_value += calc_self_healing_value
      plus = @self_healing_value.floor
      @hp += plus
      @hp = @max_hp if @hp > @max_hp
      @self_healing_value -= plus
      # ステータス異常の回復
      recover_temporary_status
      # ワープ済みフラグの解除
      @warped = false
    end

    # 毎ターンのステータス異常の回復
    def recover_temporary_status(step=1)
      recovered = super
      recovered.each do |st|
        msg = MessageManager.status_recover(st)
        @events << EventPacket.new(ShowMessageEvent, msg)
      end
    end

    def calc_self_healing_value
      @max_hp / 200.0
    end

    # 毎ターンの満腹度の現象
    def hunger
      if @stomach <= 0
        @hp -= 1 if @hp > 0
      else
        base = 1
        base = base * 2   if has_status?(:hungry)
        base = base / 2.0 if anti?(:hungry)
        subtrace_hunger_interval(base)
        if @hunger_interval <= 0
          subtrace_stomach(1)
          @hunger_interval = HUNGER_INTERVAL
        end
      end
    end

    def subtrace_hunger_interval(v)
      before = @hunger_interval
      @hunger_interval -= v
      if @stomach == 1
        if before == 3
          msg = MessageManager.get(:before_starve_1)
        elsif before == 2
          msg = MessageManager.get(:before_starve_2)
        end
      end
      @events << EventPacket.new(ShowMessageEvent, msg) if msg
    end

    def subtrace_stomach(v)
      before = @stomach
      @stomach -= v
      @stomach = 0 if @stomach < 0
      if before >= 1 && @stomach == 0
        msg = MessageManager.get(:starve)
      elsif before >= 10 && @stomach < 10
        msg = MessageManager.get(:quite_hunger)
      elsif before >= 20 && @stomach < 20
        msg = MessageManager.get(:little_hunger)
      end
      @events << EventPacket.new(ShowMessageEvent, msg) if msg
    end

    # アイテムの取得
    def get(item)
      if @items.size < PORTABLE_ITEM_NUMBER
        # アイテム欄に余裕がある場合
        item.got_by(self)
        msg = MessageManager.pick_up_item(item.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
        true
      elsif item.kind_of?(MeiroSeeker::Bullet) && # TODO: 条件の再検討
            (idx = @items.map(&:class).index(item.class))
        # アイテム欄に余裕はないが数を統合して所持できる物の場合
        @items[idx].merge(item)
        msg = MessageManager.pick_up_item(item.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
        true
      else
        # 上記いずれにも当てはまらず、拾えない場合
        msg = MessageManager.get_on_item(item.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
        msg = MessageManager.get(:cannot_pick_up_item)
        @events << EventPacket.new(ShowMessageEvent, msg)
        false
      end
    end

    # 盗める(=装備していない)アイテムの配列を返す
    def stealable_items
      # TODO: 泥棒防止能力を持っている場合は空配列を返す
      @items - %i(weapon shield ring bullet).map { |t| get_equipment(t) }.compact
    end

    # アイテムの装備
    def equip(equipment)
      eq_type = equipment.equipment_type
      eq_obj = self.class.const_get(eq_type.capitalize).new(self, equipment)
      self.instance_variable_set("@#{eq_type}", eq_obj)
      equipment.equipped_by = self
    end

    def equip?(type)
      !!self.instance_variable_get("@#{type}")
    end

    def get_equipment(type)
      return nil unless equip?(type)
      self.instance_variable_get("@#{type}").origin
    end

    def remove_equipment(type)
      self.instance_variable_set("@#{type}", nil)
    end

    def attack_or_check
      return confused_attack_or_check if has_status?(:confusion)
      return if check_target.nil?
      if check_target.hate?
        :attack
      else
        :check
      end
    end

    # 混乱時はランダムな方向に素振りまたは攻撃
    # 対象を調べる、または対象との会話にはならない
    def confused_attack_or_check
      change_direction_by_dxdy(*random_walk_dxdy)
      if check_target
        :attack
      else
        nil
      end
    end

    # 攻撃の対象を返す
    # TODO: 場合によっては複数いる
    def attack_target
      res = {}
      _x, _y = DIRECTION_STEP_MAP[@current_direction][:forward]
      res[:main] = @floor[self.x + _x, self.y + _y].character
      res[:sub] = []
      # _x, _y = DIRECTION_STEP_MAP[@current_direction][:backward]
      # res[:sub] << @floor[self.x + _x, self.y + _y].character
      # res[:sub].compact!
      res
    end

    # 自身を含む周囲8マスのモブやオブジェクトを返す
    def surrounding_objects
      res = []
      ((self.y - 1)..(self.y + 1)).each do |ay|
        ((self.x - 1)..(self.x + 1)).each do |ax|
          res << @floor[ax, ay].character || @floor[ax, ay].object
        end
      end
      res
    end

    # 部屋にいるか否かを返す
    def in_room?
      !!@floor.get_room(self.x, self.y)
    end

    # 認知可能なモブやオブジェクトを返す
    # (通路であれば周囲8マス、部屋内であれば部屋全体)
    def visible_objects
      res = []
      if room = @floor.get_room(self.x, self.y)
        room.each_coordinate do |rx, ry|
          res << @floor[rx, ry].character || @floor[rx, ry].object
        end
      else
        res = surrounding_objects
      end
      res
    end

    # 話す、調べるなどの対象を返す
    # 壁を挟んだナナメ位置の相手は対象にならない
    def check_target
      _x, _y = DIRECTION_STEP_MAP[@current_direction][:forward]
      if self.throughable?(_x, _y)
        @floor[self.x + _x, self.y + _y].character
      else
        nil
      end
    end

    # 素振り
    def swing
      @events << EventPacket.new(PlayerAttackEvent)
    end

    # モブとは異なり、複数対象に対する直接攻撃でも攻撃の演出は1回だけに
    # するため、引数として攻撃対象は複数とる
    def attack_to(targets)
      @events << EventPacket.new(PlayerAttackEvent)
      targets.each do |target|
        if randomizer.rand(100)  < self.accuracy
          damage = target.attacked_by(self)
          @events << EventPacket.new(DamageEvent, target, damage)
          # この時点でフロアから消しておくことで、直後のその他のモ
          # ブの行動で、死んだモブがいた場所に移動が可能になる
          self.kill(target) if target.dead?
        else
          msg = MessageManager.missed(self.name)
          @events << EventPacket.new(ShowMessageEvent, msg)
        end
      end
    end

    # 対象を調べる、または対象と会話する
    # 攻撃時とは異なり対象は単体
    def check_on(target)
      target.checked_events(self).each do |e|
        @events << e
      end
    end

    def attacked_by(attacker)
      damage = calc_damage(attacker, self)
      msg = MessageManager.damage(damage)
      attacker.events << EventPacket.new(ShowMessageEvent, msg)
      damage
    end

    def kill(target)
      super
      msg = MessageManager.kill(target.name)
      @events << EventPacket.new(ShowMessageEvent, msg)
      # 経験値の取得とメッセージ表示イベント
      @exp += target.exp
      msg = MessageManager.get_exp(target.exp)
      @events << EventPacket.new(ShowMessageEvent, msg)
      # レベルアップのチェック
      current_exp_level = LevelManager.get_level(@level, @exp)
      if current_exp_level > @level
        msg = MessageManager.level_up(self.name, current_exp_level)
        @events << EventPacket.new(ShowMessageEvent, msg)
        @events << EventPacket.new(PlayerLevelUpEvent, current_exp_level)
      end
    end

    def killed_by(attacker)
      super
      # TODO: ゲームオーバーイベント
    end

    def defence
      @shield ? @shield.defence : 0
    end

    # 持っている武器やステータスなどにより、大ダメージを与えることのできる
    # 敵種族を配列で返す
    def defeat
      @weapon ? @weapon.defeat : []
    end

    # 引数に指定したステータス異常の状態であるか否か
    def has_status?(sym)
      super(sym) ||
        [@weapon, @shield, @ring].map { |e| e && e.has_ability?(sym) }.any?
    end

    # 引数に指定したステータス異常に対して体制を持っているか否か
    def anti?(sym)
      super(sym) ||
        [@weapon, @shield, @ring].map { |e| e && e.anti?(sym) }.any?
    end

    # targetと場所交換が可能か？
    def switchable?(target)
      return false unless target
      # hate値が等しくかつ通過可能な位置関係であれば可能
      (self.hate? == target.hate?) &&
        target.throughable?(self.x - target.x, self.y - target.y)
    end

    private

    # 武器補正の計算
    def calc_weapon_calibration
      @weapon ? @weapon.offence : 0
    end

    # 装備に関する内部クラス
    # 主にプレーヤーキャラに重ねる装備品の画像のために使う
    class Equipment < Character
      attr_reader :origin
      attr_accessor :current_direction, :current_frame

      def initialize(player, origin)
        @player = player
        @origin = origin
        super(nil)
      end

      def width
        @origin.equipped_images.first.first.width
      end

      def height
        @origin.equipped_images.first.first.height
      end

      def image
        if @hide
          TRANSPARENCY.image
        else
          @origin.equipped_images[@current_direction][@current_frame]
        end
      end

      def strength
        @origin.strength
      end

      def anti?(sym)
        @origin.anti?(sym)
      end

      def has_ability?(sym)
        @origin.has_ability?(sym)
      end
    end

    class Weapon < Equipment
      def offence
        @origin.offence
      end

      def defeat
        @origin.defeat
      end
    end

    class Shield < Equipment
      def defence
        @origin.defence
      end
    end

    class Bullet < Equipment
      # 装備しても見た目に変わりはない
      def initialize(player, origin)
        @player = player
        @origin = origin
      end
    end

    class Ring < Equipment
      # 装備しても見た目に変わりはない
      def initialize(player, origin)
        @player = player
        @origin = origin
      end
    end
  end
end

module MyDungeonGame
  class PlayerCharacter < Character
    type :player
    update_interval 10
    name "PLAYER"
    level 1
    hp 15
    power 8
    exp 0

    attr_accessor :floor, :stomach, :max_power, :max_stomach, :money, :items

    HUNGER_INTERVAL = 10
    HP_GAIN_MIN = 2
    HP_GAIN_AMPLITUDE = 5

    def initialize(floor)
      super(PLAYER_IMAGE_PATH, floor)
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
      0
    end

    def accuracy
      PLAYER_ATTACK_ACCURACY
    end

    # 毎ターンの自然治癒
    def self_healing
      @self_healing_value += calc_self_healing_value
      plus = @self_healing_value.floor
      @hp += plus
      @hp = @max_hp if @hp > @max_hp
      @self_healing_value -= plus
    end

    def calc_self_healing_value
      @max_hp / 200.0
    end

    # 毎ターンの満腹度の現象
    def hunger
      if @stomach <= 0
        # TODO: 空腹によるHP減少
      else
        @hunger_interval -= 1
        if @hunger_interval <= 0
          @stomach -= 1
          @hunger_interval = HUNGER_INTERVAL
        end
      end
    end

    # アイテムの取得
    def get(item)
      if @items.size < PORTABLE_ITEM_NUMBER
        @items << item
        msg = MessageManager.pick_up_item(item.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
        true
      else
        msg = MessageManager.get_on_item(item.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
        msg = MessageManager.get(:cannot_pick_up_item)
        @events << EventPacket.new(ShowMessageEvent, msg)
        false
      end
    end

    # アイテムの装備
    def equip(equipment)
      self.instance_variable_set("@#{equipment.equipment_type}", equipment)
      equipment.equipped_by = self
    end

    def equip?(type)
      !!self.instance_variable_get("@#{type}")
    end

    def get_equipment(type)
      self.instance_variable_get("@#{type}")
    end

    def remove_equipment(type)
      self.instance_variable_set("@#{type}", nil)
    end

    def attack_or_check
      return if check_target.nil?
      if check_target.hate?
        :attack
      else
        :check
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

    # 認知可能なモブやオブジェクトを返す
    # (通路であれば周囲8マス、部屋内であれば部屋全体)
    def visible_objects
      res = []
      if room = @floor.get_room(self.x, self.y)
        room.each_coordinate do |rx, ry|
          res << @floor[rx, ry].character || @floor[rx, ry].object
        end
      else
        ((self.y - 1)..(self.y + 1)).each do |ay|
          ((self.x - 1)..(self.x + 1)).each do |ax|
            res << @floor[ax, ay].character || @floor[ax, ay].object
          end
        end
      end
      res
    end

    # 話す、調べるなどの対象を返す
    def check_target
      _x, _y = DIRECTION_STEP_MAP[@current_direction][:forward]
      @floor[self.x + _x, self.y + _y].character
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
          if target.dead?
            self.kill(target)
          end
        else
          msg = MessageManager.missed(self.name)
          @events << EventPacket.new(ShowMessageEvent, msg)
        end
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

    private

    # 武器補正の計算
    def calc_weapon_calibration
      @weapon ? @weapon.offence : 0
    end
  end
end

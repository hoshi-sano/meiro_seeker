module MyDungeonGame
  class PlayerCharacter < Character
    type :player
    update_interval 10
    name "PLAYER"
    level 1
    hp 15
    power 5

    attr_reader :level, :max_hp, :money
    attr_accessor :hp

    def initialize(floor)
      super(PLAYER_IMAGE_PATH, floor)
      @money = 0
      @self_healing_value = 0 # 自然治癒力
    end

    def accuracy
      PLAYER_ATTACK_ACCURACY
    end

    # 毎ターンの自然治癒
    def self_healing
      return if @hp >= @max_hp
      @self_healing_value += calc_self_healing_value
      plus = @self_healing_value.floor
      @hp += plus
      @self_healing_value -= plus
    end

    def calc_self_healing_value
      # TODO: 調整
      @level / 5.0
    end

    # 毎ターンの満腹度の現象
    def hunger
      @hunger_interal -= 1
      if @hunger_interal <= 0
        @stomach -= 1
        @hunger_interal = HUNGER_INTERAL
      end
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
      # TODO: 経験値の習得
    end

    def killed_by(attacker)
      super
      # TODO: ゲームオーバーイベント
    end
  end
end

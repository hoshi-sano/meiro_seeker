module MyDungeonGame
  class PlayerCharacter < Character
    type :player
    update_interval 10
    name "PLAYER"

    def initialize(floor)
      super(PLAYER_IMAGE_PATH, floor)
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
        # TODO: 命中判定
        @events << EventPacket.new(DamageEvent, target)
        target.attacked_by(self)
        if target.dead?
          self.kill(target)
        end
      end
    end

    def attacked_by(attacker)
      # TODO: ダメージ計算など
      damage = 5
      # @hp -= damage
      msg = MessageManager.damage(damage)
      attacker.events << EventPacket.new(ShowMessageEvent, msg)
    end

    def kill(target)
      super
      msg = MessageManager.kill(target.name)
      #target.events << EventPacket.new(ShowMessageEvent, msg)
      target.events << EventPacket.new(AddMessageEvent, msg)
      # TODO: 経験値の習得
    end

    def killed_by(attacker)
      super
      # TODO: ゲームオーバーイベント
    end
  end
end

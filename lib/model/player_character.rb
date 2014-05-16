module MyDungeonGame
  class PlayerCharacter < Character
    type :player
    update_interval 10

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
        target.attacked_by(self)
        @events << EventPacket.new(DamageEvent, target)
        if target.dead?
          self.kill(target)
        end
      end
    end

    # TODO: オーバーライド必要？
    def attacked_by(attacker)
      super
      @hp += 10
    end

    def kill(target)
      super
      # TODO: 経験値の習得
    end

    def killed
      super
      # TODO: ゲームオーバーイベント
    end
  end
end

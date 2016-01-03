module MyDungeonGame
  # 敵キャラクターのベースとなるクラス
  class EnemyCharacter < FollowPlayerCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    hate true
    name "ENEMY"
    level   1
    hp     10
    power   2
    defence 1
    exp     4
    speed   1
    skill WaitAndSee, 20
    skill ItemThrowSkill, rate: 40, item: NormalBullet

    # targetが攻撃対象か否か
    def attackable?(target)
      # 自身は攻撃不可、通過不可能な位置の相手は攻撃不可
      if (target == self) || !throughable?(target.x - self.x, target.y - self.y)
        return false
      end
      # 混乱時は誰でも攻撃する
      return true if has_status?(:panic)
      # hate値が自分と異なる相手は攻撃対象
      self.hate? != !!target.hate?
    end
  end
end

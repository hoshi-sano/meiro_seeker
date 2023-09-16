module MeiroSeeker
  # 敵キャラクターのベースとなるクラス
  class EnemyCharacter < FollowPlayerCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    hate true
    name "ENEMY"
    level   1
    hp      1
    power   2
    defence 1
    exp     4
    speed   1

    # targetが攻撃対象か否か
    def attackable?(target)
      # ワープ済の相手は攻撃不可
      return false if target.warped || @warped

      # 自身は攻撃不可、通過不可能な位置の相手は攻撃不可
      if (target == self) || !throughable?(target.x - self.x, target.y - self.y)
        return false
      end
      # 混乱時は誰でも攻撃する
      return true if has_status?(:confusion)
      # hate値が自分と異なる相手は攻撃対象
      self.hate? != !!target.hate?
    end

    # 最寄りの出入り口の座標を返す
    def nearest_gate_xy(candidates=@room.gate_coordinates)
      res = nil
      return res if candidates.empty?
      min_dist = nil
      candidates.each do |cand_x, cand_y|
        distance = calc_distance(self.x, self.y, cand_x, cand_y)
        if min_dist.nil? || (distance < min_dist)
          min_dist = distance
          res = [cand_x, cand_y]
        end
      end
      res
    end

    # 自身が部屋内にいる場合の移動先決定
    # 親クラスとは逃亡中の場合の挙動が加わったパターンが異なる
    # 逃亡中でない場合は同じ挙動
    def analyse_in_room
      if has_status?(:escape)
        @reserve_xy = nil
        dx, dy = nil, nil
        if player_xy = @room.player_xy
          # 同じ部屋にプレイヤーがいる場合
          candidates = @room.gate_coordinates
          # 部屋にgateがない場合は実際にはあり得ない程遠くにある想定にする
          gate_xy = nearest_gate_xy(candidates) || [9999, 9999]
          gate_distance = calc_distance(self.x, self.y, *gate_xy)
          @distance = calc_distance(self.x, self.y, *player_xy)
          if (gate_distance <= current_speed) ||
            # 自身のspeedの範囲に出入り口がある場合、または
             (gate_distance <= calc_distance(*gate_xy, *player_xy))
            # 出入り口との距離がプレイヤーより近い場合はそこへ逃げ込む
            return go_toward(gate_xy, false)
          else
            # そうでない場合はプレイヤーから離れる
            return go_toward(player_xy, true)
          end
        else
          super
        end
      else
        super
      end
    end
  end
end

require_relative './item_thief'

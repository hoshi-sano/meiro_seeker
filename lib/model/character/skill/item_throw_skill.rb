module MyDungeonGame
  class Character
    # アイテム投げスキル
    class ItemThrowSkill < Skill
      class << self
        def usable?(user)
          room = user.instance_variable_get(:@room)
          if room && room.player_xy
            # 部屋の中にいる場合、直線上にプレイヤーがいる場合発動可能
            user.alignment_with_player?
          else
            # 部屋の以外にいる場合、プレイヤーに隣接する場合発動可能
            user.adjoin_player?
          end
        end

        def event
          ItemThrowEvent
        end

        def event_args(user)
          # TODO: 任意の投げ物を使えるようにする
          [user, NormalBullet.new(1)]
        end

        # プレイヤーの方向を見る
        def pre_invoke(user)
          return unless xy = user.straight_player_xy
          user.change_direction_by_dxdy(xy[0] - user.x, xy[1] - user.y)
        end
      end
    end
  end
end

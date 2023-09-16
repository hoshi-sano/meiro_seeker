module MeiroSeeker
  class Character
    # 様子見スキル
    class WaitAndSee < Skill
      class << self
        # プレイヤーと隣接している場合発動可能
        def usable?(user)
          user.adjoin_player?
        end

        def event
          ShowMessageEvent
        end

        def event_args(user)
          MessageManager.wait_and_see(user.name)
        end

        # 隣接するプレイヤーの方向を見る
        def pre_invoke(user)
          return unless xy = user.neighboring_player_xy
          user.change_direction_by_dxdy(xy[0] - user.x, xy[1] - user.y)
        end
      end
    end
  end
end

module MeiroSeeker
  class Character
    # アイテムを盗み、ワープ後に逃亡状態となるスキル
    class ItemStealSkill < Skill
      class << self
        # 攻撃可能な位置にプレイヤーがいる場合発動可能
        # 自身が逃亡中は発動不可能
        # プレイヤーが泥棒よけを持っている場合は発動不可能
        def usable?(user)
          return false if user.has_status?(:escape)
          player = user.neighboring_player
          return false unless player
          !player.has_status?(:anti_steal) && user.attackable?(player)
        end

        def event
          ItemStealEvent
        end

        def event_args(user)
          [user, user.neighboring_player, after_state_options(user)]
        end

        # 盗み実行後の状態変更に関するオプションをHash形式で返す
        # 例) { escape: true, speed_up: true }
        def after_state_options(user)
          Array((user.class.get_skills[self] || {})[:after_state])
            .map { |st| [st, true] }.to_h
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

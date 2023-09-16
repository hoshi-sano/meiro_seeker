module MeiroSeeker
  class Character
    # 強制的に相手をワープさせるスキル
    class ForceWarpSkill < Skill
      class << self
        # 攻撃可能な位置にプレイヤーがいる場合発動可能
        # TODO: 能力によってレンジ指定可能にする
        def usable?(user)
          return false if user.has_status?(:escape)
          player = user.neighboring_player
          player ? user.attackable?(player) : false
        end

        def event
          WarpEvent
        end

        def event_args(user)
          [user.neighboring_player]
        end

        # スキル実行時の表示メッセージ
        def invoke_skill_message(user)
          (user.class.get_skills[self] || {})[:message]
        end

        # 隣接するプレイヤーの方向を見る
        def pre_invoke(user)
          return unless xy = user.neighboring_player_xy
          user.change_direction_by_dxdy(xy[0] - user.x, xy[1] - user.y)
          if msg = invoke_skill_message(user)
            user.events << EventPacket.new(ShowMessageEvent, msg)
          end
        end
      end
    end
  end
end

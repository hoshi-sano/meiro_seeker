module MeiroSeeker
  class Character
    class Skill
      class << self
        # 現在の状況において利用可能かどうかを返す
        def usable?(user)
          false
        end

        # このスキルにおいて実行されるイベント
        def event
        end

        # イベント用引数
        def event_args(user)
        end

        # スキル発動前処理
        def pre_invoke(user)
        end

        # スキル発動
        def invoke(user)
          pre_invoke(user)
          user.events << EventPacket.new(event, *event_args(user))
          post_invoke(user)
        end

        # スキル発動後処理
        def post_invoke(user)
        end
      end
    end
  end
end

# load skill dir
here = File.dirname(File.expand_path(__FILE__))
skill_dir = File.join(here, "skill")
Dir.entries(skill_dir).each do |fname|
  if fname =~ /\.rb$/
    require File.join(skill_dir, fname)
  end
end

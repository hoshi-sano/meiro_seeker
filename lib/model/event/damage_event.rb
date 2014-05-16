module MyDungeonGame
  # 被ダメージ演出
  module DamageEvent
    module_function

    def create(scene, target)
      scene.instance_eval do
        # TODO: 最終的には点滅はいらない。画像が変わるだけでいい。
        res = Event.new {|e| target.show_switch; e.finalize }
        anime_length = CHARACTER_DAMAGE_ANIMATION_LENGTH
        anime_length.times do |i|
          if i < anime_length - 1
            ev = i.even? ? Event.new {|e| target.show_switch; e.finalize } :
              Event.new {|e| e.finalize }
          else
            ev = Event.new {|e| target.show; e.finalize }
          end
          res.set_next(ev)
        end
        res
      end
    end
  end
end

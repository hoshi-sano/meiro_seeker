module MyDungeonGame
  # 死に演出
  module DeadEvent
    module_function

    def create(scene, target)
      scene.instance_eval do
        res = nil
        if target.type == :player
          # TODO: プレイヤーの死
        else
          res = Event.new {|e| target.show_switch; e.finalize }
          anime_length = CHARACTER_DEATH_ANIMATION_LENGTH
          anime_length.times do |i|
            if i < anime_length - 1
              ev = i.even? ? Event.new {|e| target.show_switch; e.finalize } :
                Event.new {|e| target.death_animating = false; e.finalize }
            else
              ev = Event.new {|e| @mobs.delete(target); e.finalize }
            end
            res.set_next(ev)
          end
        end
        res
      end
    end
  end
end

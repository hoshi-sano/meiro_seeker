module MyDungeonGame
  # HP回復演出
  module HpRecoverEvent
    module_function

    def create(scene, target, point, gain=nil)
      scene.instance_eval do
        hp_diff = 0
        recover = Event.new do |e|
          hp_diff = target.max_hp - target.hp

          if hp_diff.zero? && gain
            target.max_hp += gain
            target.hp = target.max_hp
            msg = MessageManager.hp_gain(gain)
          else
            target.hp += point
            target.hp = target.max_hp if target.hp > target.max_hp
            msg = MessageManager.hp_recover(hp_diff)
          end
          e.set_next(ShowMessageEvent.create(self, msg))

          tick
          e.finalize
        end

        recover
      end
    end
  end
end

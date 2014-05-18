module MyDungeonGame
  module PlayerLevelUpEvent
    module_function

    def create(scene, next_level)
      scene.instance_eval do
        Event.new do |e|
          # TODO: レベルアップ音の再生
          diff = next_level - @player.level
          diff.times { @player.level_up }
          e.finalize
        end
      end
    end
  end
end

module MyDungeonGame
  class GeneralManager
    class << self
      def play
        initialize_game if !@initialized
        @current_scene.update
      end

      def initialize_game
        @dungeon = DungeonManager.create_dungeon
        @current_scene = ExplorationScene.new
        @initialized = true
      end
    end
  end
end

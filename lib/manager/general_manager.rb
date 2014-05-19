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

      def next_floor(floor, player)
        floor_num = floor.storey + 1
        player.events = []
        @current_scene = ExplorationScene.new(floor_num, player)
      end
    end
  end
end

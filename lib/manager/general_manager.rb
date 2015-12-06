require 'yaml'

module MyDungeonGame
  # ゲーム全体を管理するクラス
  class GeneralManager
    class << self
      def play
        initialize_game if !@initialized
        @current_scene.update
      end

      def initialize_game
        @dungeon  = DungeonManager.create_dungeon
        @scenes   = YAML.load_file(SCENES_PATH)
        @current_scene = TownScene.new(1, nil, @scenes[:initial_scene])
        @initialized = true
      end

      def map_data
        @map_data ||= YAML.load_file(MAP_DATA_PATH)
      end

      def next_floor(floor, player)
        floor_num = floor.storey + 1
        player.events = []
        @current_scene = @current_scene.next_scene.new(floor_num, player)
      end
    end
  end
end

require 'yaml'

module MyDungeonGame
  # ゲーム全体を管理するクラス
  class GeneralManager
    class << self
      def play
        initialize_game if !@initialized
        @current_scene.update
      end

      # ゲーム開始時に1回だけ呼ばれる
      def initialize_game
        @scenes = YAML.load_file(SCENES_PATH)
        scene_info = @scenes[:initial_scene]
        scene_klass = MyDungeonGame.const_get(scene_info[:scene_class])
        @current_scene = scene_klass.new
        @initialized = true
      end

      def create_new_game_data
        @dungeon = DungeonManager.create_dungeon
        next_scene_id = @scenes[:initial_scene][:next_scene_id]
        scene_info = @scenes[next_scene_id]
        scene_klass = MyDungeonGame.const_get(scene_info[:scene_class])
        @current_scene = scene_klass.new(1, nil, scene_info)
      end

      def set_game_data(game_data)
        @dungeon       = game_data[:dungeon]
        @current_scene = game_data[:current_scene]
        DungeonManager.instance_variable_set(:@current_dungeon, @dungeon)
        @current_scene.after_load
      end

      def map_data
        @map_data ||= YAML.load_file(MAP_DATA_PATH)
      end

      def next_floor(floor, player)
        floor_num = floor.storey + 1
        player.events = []
        @current_scene = @current_scene.next_scene.new(floor_num, player)
        save
      end

      # ゲームデータをロードする
      def load
        game_data = nil
        if File.exist?(SAVE_FILE_PATH)
          game_data = Marshal.load(File.binread(SAVE_FILE_PATH))
        end
        game_data
      end

      # ゲームデータを保存する
      def save
        if File.exist?(SAVE_FILE_PATH)
          File.rename(SAVE_FILE_PATH, OLD_SAVE_FILE_PATH)
        end

        # Marshal.dump 不可能な要素をいったん省く
        @current_scene.before_save
        game_data = { dungeon: @dungeon, current_scene: @current_scene }
        File.open(SAVE_FILE_PATH, 'wb') do |f|
          f.write(Marshal.dump(game_data))
        end
        @current_scene.after_save
      end

      # ゲームデータを保存し、ゲームを中断する
      def save_and_break
        save
        scene_info = @scenes[:initial_scene]
        scene_klass = MyDungeonGame.const_get(scene_info[:scene_class])
        @current_scene = scene_klass.new
      end
    end
  end
end

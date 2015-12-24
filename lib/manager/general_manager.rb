require 'yaml'

module MyDungeonGame
  # ゲーム全体を管理するクラス
  class GeneralManager
    DEFAULT_PLAYER_DATA = {
      name:              '＊＊＊＊',
      reached_floor_num: 1,
      stocked_items:     [],
    }

    class << self
      def play
        initialize_game if !@initialized
        @current_scene.update
      end

      def current_scene
        @current_scene
      end

      # ゲーム開始時に1回だけ呼ばれる
      def initialize_game
        @scenes = YAML.load_file(SCENES_PATH)
        @scenes.each { |key, scene_info| scene_info[:id] = key }
        scene_info = @scenes[:initial_scene]
        scene_klass = MyDungeonGame.const_get(scene_info[:scene_class])
        @current_scene = scene_klass.new
        @initialized = true
      end

      def create_new_game_data
        @player_data = DEFAULT_PLAYER_DATA.dup
        @dungeon = DungeonManager.create_dungeon
        @next_scene_id = @scenes[:initial_scene][:next_scene_id]
        scene_info = @scenes[@next_scene_id]
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

      def player_data
        @player_data || {}
      end

      def player_name
        player_data[:name]
      end

      def reached_floor_num
        player_data[:reached_floor_num]
      end

      # 最深到達度の更新
      def reached_floor(storey)
        if player_data[:reached_floor_num].to_i < storey
          @player_data[:reached_floor_num] = storey
        end
      end

      def next_floor(floor, player, stairs)
        storey = floor.storey + stairs.storey_add_value
        player.events = []
        # @current_sceneがnext_scene_idを返す場合はそのシーンに切り替え
        # そうでなくstairsがnext_scene_idを返す場合はそのシーンに切り替え
        # いずれでもない場合はシーンは変えず、階層だけ変更する
        @next_scene_id =
          @current_scene.next_scene_id ||
          stairs.next_scene_id ||
          @current_scene.scene_id
        next_scene_info = @scenes[@next_scene_id]
        storey = next_scene_info[:storey] if next_scene_info[:storey]
        scene_klass = MyDungeonGame.const_get(next_scene_info[:scene_class])
        @current_scene = scene_klass.new(storey, player, next_scene_info)
        reached_floor(storey)
        save
      end

      # ゲームデータをロードする
      def load
        game_data = nil
        if File.exist?(SAVE_FILE_PATH)
          game_data = Marshal.load(File.binread(SAVE_FILE_PATH))
        end
        @player_data = DEFAULT_PLAYER_DATA.dup.merge(game_data[:player_data])
        game_data
      end

      # ゲームデータを保存する
      def save
        if File.exist?(SAVE_FILE_PATH)
          File.rename(SAVE_FILE_PATH, OLD_SAVE_FILE_PATH)
        end

        # Marshal.dump 不可能な要素をいったん省く
        @current_scene.before_save
        game_data = {
          player_data:   @player_data,
          dungeon:       @dungeon,
          current_scene: @current_scene,
        }
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

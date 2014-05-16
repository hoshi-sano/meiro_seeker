module MyDungeonGame
  class DungeonManager
    DUNGEON_DEFAULT_OPTS = {
      width:           WIDTH_TILE_NUM,
      height:          HEIGHT_TILE_NUM,
      min_room_number: DEFAULT_MIN_ROOM_NUM,
      max_room_number: DEFAULT_MAX_ROOM_NUM,
      min_room_width:  DEFAULT_MIN_ROOM_WIDTH,
      min_room_height: DEFAULT_MIN_ROOM_HEIGHT,
      max_room_width:  DEFAULT_MAX_ROOM_WIDTH,
      max_room_height: DEFAULT_MAX_ROOM_HEIGHT,
      block_split_factor: BLOCK_SPLIT_FACTOR,
    }

    class <<self
      def create_dungeon
        @current_dungeon = Meiro.create_dungeon(DUNGEON_DEFAULT_OPTS)
      end

      def create_floor
        @current_floor = @current_dungeon.generate_random_floor(Floor, Room)
        @current_floor.classify!(:detail)
        @current_floor
      end

      def randomizer
        if @current_dungeon
          @current_dungeon.instance_variable_get(:@randomizer)
        else
          nil
        end
      end
    end
  end
end

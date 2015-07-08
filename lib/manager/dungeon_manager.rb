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

      # TODO: ここを yaml などから生成できるようにする
      def create_town_floor
        # まっさらなフロアの生成
        args = [@current_dungeon, WIDTH_TILE_NUM, HEIGHT_TILE_NUM,
                WIDTH_TILE_NUM - 2, HEIGHT_TILE_NUM - 2,
                WIDTH_TILE_NUM - 2, HEIGHT_TILE_NUM - 2,]
        f = Meiro::Floor.new(*args)
        f.extend(Meiro::Dungeon::FloorInitializer)
        f.extend(Floor)
        Meiro::Block.set_mixin_room_module(Room)
        f.instance_eval { initialize }

        # 一つの区画と部屋を生成
        root_block = f.instance_variable_get(:@root_block)
        room = root_block.send(:create_room, 5, 5)
        root_block.put_room(room)
        room.relative_x = Meiro::Block::MARGIN
        room.relative_y = Meiro::Block::MARGIN
        f.apply_rooms_to_map

        # 障害物を配置
        base_map = f.instance_variable_get(:@base_map)
        base_map[2, 2] = Meiro::Tile::Wall.new

        f.classify!(:detail)
        @current_floor = f
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

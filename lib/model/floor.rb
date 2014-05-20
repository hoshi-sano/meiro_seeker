module MyDungeonGame
  # Meiro::Floorクラスの拡張
  module Floor
    attr_reader :storey

    def set_storey(num)
      @storey = num
    end

    # キャラクターが不在のマスの座標を返す
    def get_no_one_xy(randomizer=nil)
      randomizer ||= Random.new
      x, y = nil, nil
      until x && y && @base_map[x, y].empty?
        all_rooms_xy = self.all_room_tiles_xy
        x, y = all_rooms_xy[randomizer.rand(all_rooms_xy.size)]
      end
      [x, y]
   end

    # (x1, y1)座標にいるキャラクターが
    # (x2, y2)座標へ通過可能かどうかを返す
    def throughable?(x1, y1, x2, y2)
      # 角での斜め移動を禁止する
      @base_map[x1, y2].walkable? &&
        @base_map[x2, y1].walkable? &&
        @base_map[x2, y2].walkable?
    end

    # (x1, y1)座標にいるキャラクターが
    # (x2, y2)座標に移動可能かどうかを返す
    def movable?(x1, y1, x2, y2)
      # 誰かが先に存在したら移動不可
      @base_map[x2, y2].no_one? &&
        throughable?(x1, y1, x2, y2)
    end

    # (x, y)座標にいるキャラクターを排除する
    def remove_character(x, y)
      @base_map[x, y].clear_character
    end

    # (x1, y1)座標にいるキャラクターを(x2, y2)座標に移動する
    def move_character(x1, y1, x2, y2)
      target = @base_map[x1, y1].character
      @base_map[x1, y1].clear_character
      target.prev_x = x1
      target.prev_y = y1
      target.x = x2
      target.y = y2
      @base_map[x2, y2].character = target
    end

    # (x, y)座標の床の探索済みフラグを立てる。
    # このとき、通路または出入口であれば周囲8マスまで、部屋内であれば部
    # 屋全体のマスまで探索済みとする。
    def searched(x, y)
      if room = get_room(x, y)
        room.searched!
      else
        ((y - 1)..(y + 1)).each do |ay|
          ((x - 1)..(x + 1)).each do |ax|
            self[ax, ay].searched!
          end
        end
      end
    end
  end
end

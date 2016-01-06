module MyDungeonGame
  # Meiro::Floorクラスの拡張
  module Floor
    attr_reader :storey

    # 階層
    def set_storey(num)
      @storey = num
    end

    # 表示範囲のxy座標でeachをまわす
    def each_tile_for_display(center_x, center_y, &block)
      range_y = (center_y - DISPLAY_RANGE_Y)..(center_y + DISPLAY_RANGE_Y)
      range_x = (center_x - DISPLAY_RANGE_X)..(center_x + DISPLAY_RANGE_X)
      range_y.each do |y|
        range_x.each do |x|
          next if @base_map[x, y].nil?
          yield(x, y, @base_map[x, y])
        end
      end
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

    # (x2, y2)座標にキャラクターが不在の場合に、(x1, y1)座標にいるキャ
    # ラクターが(x2, y2)座標へ通過可能かどうかを返す
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

    # (x1, y1)座標にいるキャラクターが
    # (x2, y2)座標にいるキャラクターと場所交換可能か？
    def switchable?(dash, x1, y1, x2, y2)
      # ダッシュボタンを押していない場合は不可
      return false unless dash
      # 移動先に誰かが存在しない場合は不可
      player = @base_map[x1, y1].character
      target = @base_map[x2, y2].character
      return false unless player && target
      # hate値が等しくかつ通過可能な位置関係であれば可能
      (player.hate? == target.hate?) &&
        throughable?(x1, y1, x2, y2)
    end

    # (x1, y1)座標にいるキャラクターと(x2, y2)座標に
    # いるキャラクターの位置を交換する
    def switch_character(x1, y1, x2, y2)
      a = @base_map[x1, y1].character
      b = @base_map[x2, y2].character
      [[a, x1, y1, x2, y2],
       [b, x2, y2, x1, y1]].each do |target, prev_x, prev_y, to_x, to_y|
        target.prev_x = prev_x
        target.prev_y = prev_y
        target.x = to_x
        target.y = to_y
        @base_map[to_x, to_y].character = target
      end
    end

    # 引数が1つの場合は引数のキャラクターを探索して排除する
    # 引数が2つの場合は(x, y)座標にいるキャラクターを排除する
    def remove_character(*args)
      case args.size
      when 1
        character = args.first
        each_tile do |x, y, tile|
          tile.clear_character if tile.character == character
        end
      when 2
        x, y = *args
        @base_map[x, y].clear_character
      end
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

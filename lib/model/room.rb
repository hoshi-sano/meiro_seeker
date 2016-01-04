module MyDungeonGame
  # Meiro::Roomクラスの拡張
  module Room
    def floor
      @block.instance_variable_get(:@floor)
    end

    # 部屋内にプレイヤーがいる場合、その座標を返す。
    # 部屋内にプレイヤーがいない場合はnilを返す。
    # 部屋の出入り口も部屋内に含む。
    def player_xy
      res = nil
      each_coordinate do |x, y|
        if chara = floor[x, y].character
          res = [x, y] if chara.type == :player
        end
      end
      return res if res
      gate_coordinates.each do |x, y|
        if chara = floor[x, y].character
          res = [x, y] if chara.type == :player
        end
      end
      res
    end

    def searched?
      !!@searched
    end

    # 部屋全体のマスの探索済みフラグを立てる
    def searched!
      return if @searched
      self.each_coordinate do |rx, ry|
        floor[rx, ry].searched!
      end
      gate_coordinates.each do |gx, gy|
        floor[gx, gy].searched!
      end
      @searched = true
    end
  end
end

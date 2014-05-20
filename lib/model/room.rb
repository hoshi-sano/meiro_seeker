module MyDungeonGame
  # Meiro::Roomクラスの拡張
  module Room
    def floor
      @block.instance_variable_get(:@floor)
    end

    # 部屋内にプレイヤーがいる場合、その座標を返す。
    # 部屋内にプレイヤーがいない場合はnilを返す。
    def player_xy
      res = nil
      each_coordinate do |x, y|
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
        floor[rx, ry].searched = true
      end
      gate_coordinates.each do |gx, gy|
        floor[gx, gy].searched = true
      end
      @searched = true
    end
  end
end

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
  end
end

# 共通で使用する便利メソッドの定義
module MeiroSeeker
  module HelperMethods
    def calc_distance(x1, y1, x2, y2)
      (x1 - x2).abs + (y1 - y2).abs
    end

    def randomizer
      DungeonManager.randomizer
    end

    def random_select(array)
      array[randomizer.rand(array.size)]
    end
  end
end

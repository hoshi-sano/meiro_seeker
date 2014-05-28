module MyDungeonGame
  # 武器の基本となるクラス
  class Weapon < Equipment
    TYPE = :weapon

    # 基本性能
    # 見た目上の強さで、あくまで目安
    def strength
      @base_strength + @calibration
    end

    # 実際にダメージ計算などに使われる値
    def offence
      if @calibration_cache == @calibration
        @strength_cache
      else
        @calibration_cache = @calibration
        c = @calibration
        base = @base_strength
        inclination = ((Math.log(base + 1) / Math.log(1.6)) ** 2) / 50
        intercept   = (Math.log((base / 5) + 1) / Math.log(1.6)) ** 2
        if c >= 0
          @strength_cache = c * inclination + intercept
        else
          @strength_cache = intercept * (base * c) / base
        end
        @strength_cache
      end
    end
  end
end

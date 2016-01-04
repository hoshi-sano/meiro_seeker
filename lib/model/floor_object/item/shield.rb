module MyDungeonGame
  # 盾の基本となるクラス
  class Shield < Equipment
    TYPE = :shield

    type  :item
    image IMAGES[:shield]

    class << self
      def get_type
        if self == Shield
          super
        else
          Shield.get_type
        end
      end
    end

    def image
      Shield.default_image
    end

    def order
      if self.equipped?
        ORDER[:equipped_shield]
      else
        ORDER[:shield]
      end
    end

    # 基本性能
    def strength
      @base_strength + @calibration
    end

    # 実際にダメージ計算などに使われる値
    def defence
      if @calibration_cache == @calibration
        @strength_cache
      else
        @calibration_cache = @calibration
        c = @calibration
        base = @base_strength
        inclination = (((Math.log(base + 1) / Math.log(1.6)) ** 2) / 50) + 0.5
        intercept   = (Math.log((base / 3) + 1) / Math.log(1.6)) ** 2
        if c >= 0
          fraction = (c * inclination) + intercept
          @strength_cache = (c.even?) ? fraction.round : fraction.to_i

        else
          @strength_cache = (intercept * (base + c) / base).round
        end
      end
    end

    def calc_base_hit_damage
      # TODO:
      0
    end
  end
end

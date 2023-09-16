module MeiroSeeker
  # 指輪の基本となるクラス
  class Ring < Equipment
    TYPE = :ring

    type  :item
    image IMAGES[:ring]

    class << self
      def get_type
        if self == Ring
          super
        else
          Ring.get_type
        end
      end
    end

    def image
      Ring.default_image
    end

    def order
      if self.equipped?
        ORDER[:equipped_ring]
      else
        ORDER[:ring]
      end
    end
  end
end

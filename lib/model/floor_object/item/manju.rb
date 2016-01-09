module MyDungeonGame
  # まんじゅう系アイテムの基本クラス
  class Manju < Item
    type  :item
    image IMAGES[:manju]

    class << self
      def get_type
        if self == Manju
          super
        else
          Manju.get_type
        end
      end

      def recover_point(val)
        @recover_point = val
      end

      def gain(val)
        @gain = val
      end
    end

    def image
      Manju.default_image
    end

    def order
      ORDER[:manju]
    end

    def recover_point
      self.class.instance_variable_get(:@recover_point) || 0
    end

    def gain
      self.class.instance_variable_get(:@gain) || 0
    end

    def effect_event(scene)
      ParamRecoverEvent
        .create(scene, scene.player, :stomach, recover_point, gain)
    end
  end
end

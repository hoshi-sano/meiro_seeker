module MyDungeonGame
  # 薬系アイテムの基本クラス
  class Potion < Item
    type  :item
    image IMAGES[:potion]

    class << self
      def get_type
        if self == Potion
          super
        else
          Potion.get_type
        end
      end
    end

    def image
      Potion.default_image
    end

    def order
      ORDER[:potion]
    end
  end
end

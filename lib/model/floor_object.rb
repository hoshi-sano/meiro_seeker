module MyDungeonGame
  # フロアに落ちているもの、設置されているものの基本クラス
  # （アイテム、階段、罠など）
  class FloorObject
    class << self
      def type(value)
        @type = value
      end

      def get_type
        @type || :item
      end

      def image(value)
        @image = value
      end

      def default_image
        @image
      end
    end

    attr_reader :image, :type
    attr_accessor :x, :y, :searched

    def initialize
      @type = self.class.get_type
      @searched = false
    end

    def image
      self.class.default_image
    end

    def width
      image.width
    end

    def height
      image.height
    end

    def searched?
      !!@searched
    end

    def searched!
      @searched = true
    end
  end
end

require 'floor_object/stairs'
require 'floor_object/transparent_stairs'
require 'floor_object/item'
require 'floor_object/item/equipment'
require 'floor_object/item/weapon'
require 'floor_object/item/shield'
require 'floor_object/item/bullet'
# 武器
require 'floor_object/item/sabel'
# 盾
require 'floor_object/item/iron_shield'
# 弾
require 'floor_object/item/normal_bullet'
# 薬
require 'floor_object/item/hp_recover_item'
require 'floor_object/item/kizugusuri'
require 'floor_object/item/kaifuku_no_kusuri'
require 'floor_object/item/chikara_no_kusuri'
# まんじゅう
require 'floor_object/item/niku_man'
# 魔導書
require 'floor_object/item/grimoire'

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
      @image = self.class.default_image
      @searched = false
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def searched?
      !!@searched
    end

    def searched!
      @searched = true
    end
  end
end

require 'stairs'

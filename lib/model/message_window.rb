module MyDungeonGame
  class MessageWindow
    class << self
      def bg_image(image)
        @image = image
      end

      def image
        @image
      end
    end

    bg_image ViewProxy.rect(600, 100, [0, 0, 120], 140)

    attr_reader :image

    def initialize
      @image = self.class.image
    end

    def width
      @image.width
    end

    def height
      @image.height
    end
  end
end

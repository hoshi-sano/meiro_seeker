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

    bg_image ViewProxy.rect(*WINDOW_POSITION[:message],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    attr_reader :image, :message, :font_type

    def initialize(message, speaker=nil, font_type=:regular)
      @message = message
      @speaker = speaker
      @font_type = font_type
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

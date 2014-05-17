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

    attr_reader :image, :font_type
    attr_accessor :message

    def initialize(message, speaker=nil, font_type=:regular)
      @message = message
      @speaker = speaker
      @font_type = font_type
      @image = self.class.image
      @ttl = 100 # TODO: 調整
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def init_ttl
      @ttl = 100 # TODO: 調整
    end

    def tick
      @ttl -= 1
    end

    def permanence!
      @ttl = -1
    end

    def permanent?
      @ttl < 0
    end

    def alive?
      @ttl > 0
    end
  end
end

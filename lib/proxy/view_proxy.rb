module MyDungeonGame
  class ViewProxy
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @surface = RenderTarget.new(@width, @height)
    end

    def reserve_draw(x, y, obj, z_idx=0)
      @surface.draw(x, y, obj, z_idx)
    end

    def exec_draw(x=0, y=0)
      @surface.update
      Window.draw(x, y, @surface)
    end

    class << self
      def rect(width, height, color=[255, 255, 255], alpha=255)
        Rect.new(width, height, color, alpha)
      end
    end

    class Rect
      attr_reader :image

      def initialize(width, height, color, alpha)
        _color = [alpha, *color]
        @image = Image.new(width, height, _color)
      end

      def width
        @image.width
      end

      def height
        @image.height
      end
    end
  end
end

module MeiroSeeker
  class ViewProxy
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @surface = RenderTarget.new(@width, @height)
    end

    def reserve_draw(x, y, obj, z_idx=0, opts={})
      opts[:z] = z_idx
      @surface.draw_ex(x, y, obj, opts)
    end

    def reserve_draw_text(x, y, text, font, z_idx=0)
      opts = {z: z_idx}
      @surface.draw_font(x, y, text, font, opts)
    end

    def exec_draw(x=0, y=0)
      @surface.update
      Window.draw(x, y, @surface)
    end

    class << self
      def rect(width, height, color=[255, 255, 255], alpha=255)
        Rect.new(width, height, color, alpha)
      end

      def box(width, height, color=[255, 255, 255], alpha=255)
        Box.new(width, height, color, alpha)
      end
    end

    class ImageObject
      attr_reader :image

      def initialize(path)
        @image = FileLoadProxy.load_image(path)
      end

      def width
        @image.width
      end

      def height
        @image.height
      end
    end

    class Rect < ImageObject
      def initialize(width, height, color, alpha)
        _color = [alpha, *color]
        @image = Image.new(width, height, _color)
      end
    end

    class Box < Rect
      def initialize(width, height, color, alpha)
        _color = [alpha, *color]
        args = [0, 0, width, height, _color]
        @image = Image.new(width, height).box(*args)
      end
    end
  end
end

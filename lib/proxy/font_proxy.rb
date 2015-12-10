module MyDungeonGame
  class FontProxy
    FONT_PATHES.each do |path|
      Font.install(path)
    end

    FONTS = {
      regular: Font.new(22, 'PixelMplus12'),
    }

    class << self
      def get_font(type)
        FONTS[type]
      end
    end
  end
end

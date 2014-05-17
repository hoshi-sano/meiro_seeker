module MyDungeonGame
  class FontProxy
    FONTS = {
      # TODO: パラメータ調整
      regular: Font.new(20),
    }

    class << self
      def get_font(type)
        FONTS[type]
      end
    end
  end
end

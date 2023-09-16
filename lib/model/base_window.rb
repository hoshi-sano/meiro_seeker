module MeiroSeeker
  # ウインドウの基本クラス
  class BaseWindow
    class << self
      def bg_image(image)
        @image = image
      end

      def image
        @image
      end
    end

    attr_reader :image, :font_type

    def initialize(font_type=:regular)
      @font_type = font_type
      @image = self.class.image
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def text
      ''
    end
  end
end

require 'window/message_window'
require 'window/yes_no_window'
require 'window/menu_window'
require 'window/sub_menu_window'
require 'window/item_window'
require 'window/item_menu_window'
require 'window/item_note_window'
require 'window/status_window'
require 'window/underfoot_item_window'
require 'window/key_config_window'
require 'window/game_starting_window'
require 'window/game_data_window'

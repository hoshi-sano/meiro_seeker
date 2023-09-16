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

require_remote "lib/model/window/message_window.rb"
require_remote "lib/model/window/yes_no_window.rb"
require_remote "lib/model/window/menu_window.rb"
require_remote "lib/model/window/sub_menu_window.rb"
require_remote "lib/model/window/item_window.rb"
require_remote "lib/model/window/item_menu_window.rb"
require_remote "lib/model/window/item_note_window.rb"
require_remote "lib/model/window/status_window.rb"
require_remote "lib/model/window/underfoot_item_window.rb"
require_remote "lib/model/window/key_config_window.rb"
require_remote "lib/model/window/game_starting_window.rb"
require_remote "lib/model/window/game_data_window.rb"

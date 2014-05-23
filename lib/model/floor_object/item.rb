module MyDungeonGame
  # アイテムの基本となるクラス
  class Item < FloorObject
    class << self
      def name(value)
        @name = value
      end

      def get_name
        @name || "BaseItem"
      end
    end

    MENU_WORDS = {
      use:   MessageManager.get('item_menu.use'),
      throw: MessageManager.get('item_menu.throw'),
      put:   MessageManager.get('item_menu.put'),
      note:  MessageManager.get('item_menu.note'),
    }

    type :item
    image FileLoadProxy.load_image(STAIRS_IMAGE_PATH) # TODO: あとで変える

    attr_reader :name

    def initialize(scene)
      super()
      @name = self.class.get_name
      @scene = scene
    end

    def event
      ClearMenuWindowEvent.create(@scene)
    end

    # アイテム欄から選択された際に表示するメニュー
    def menu_event
      choices = {
        MENU_WORDS[:use]   => lambda { self.use_event },
        MENU_WORDS[:throw] => lambda { ClearMenuWindowEvent.create(@scene) },
        MENU_WORDS[:put]   => lambda { ClearMenuWindowEvent.create(@scene) },
        MENU_WORDS[:note]  => lambda { ClearMenuWindowEvent.create(@scene) },
      }
      item_menu_window = ItemMenuWindow.new(choices)
      ShowMenuEvent.create(@scene, item_menu_window)
    end
  end
end


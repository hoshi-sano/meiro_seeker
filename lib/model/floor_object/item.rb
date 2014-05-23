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
      use:   MessageManager.get('items.menu.use'),
      throw: MessageManager.get('items.menu.throw'),
      put:   MessageManager.get('items.menu.put'),
      note:  MessageManager.get('items.menu.note'),
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

    def use_event
      # 全ウインドウの消去
      e = ClearMenuWindowEvent.create(@scene)
      # 使用した旨のメッセージの表示
      e.set_next(ShowMessageEvent.create(@scene, use_message))
      # アイテム使用演出
      e.set_next(use_action_event)
      # 効果
      e.set_next(effect_event)
      e
    end

    def use_message
      MessageManager.player_use_item(@scene.player.name, @name)
    end

    def use_action_event
      Event.new {|e| e.finalize }
    end

    def effect_event
      Event.new {|e| e.finalize }
    end
  end
end


module MyDungeonGame
  # 足元選択時のイベント
  module UnderfootEvent
    module_function

    def create(scene)
      scene.instance_eval do
        obj = @floor[@player.x, @player.y].object
        if obj.nil?
          # 足元に何もない場合
          e = ClearMenuWindowEvent.create(self)
          msg = MessageManager.get(:no_item_underfoot)
          msg_event = ShowMessageEvent.create(self, msg)
          e.set_next(msg_event)
          e
        elsif obj.type == :stairs
          # 足元が階段の場合
          e = ClearMenuWindowEvent.create(self)
          e.set_next(GoToNextFloorEvent.create(self))
          e
        else
          # 足元にアイテムが落ちている場合
          iw = UnderfootItemWindow.new([obj])
          ShowMenuEvent.create(self, iw)
        end
      end
    end
  end
end

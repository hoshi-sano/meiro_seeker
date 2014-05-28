module MyDungeonGame
  # アイテム装備解除イベント
  module RemoveEquipmentEvent
    module_function

    def create(scene, equipment)
      scene.instance_eval do
        remove = Event.new do |e|
          equipment.removed!
          tick
          e.finalize
        end
        remove.set_next(ClearMenuWindowEvent.create(self))
        msg = MessageManager.remove_item(equipment.name)
        remove.set_next(ShowMessageEvent.create(self, msg))
        remove
      end
    end
  end
end

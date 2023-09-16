module MeiroSeeker
  # アイテム装備イベント
  module EquipEvent
    module_function

    def create(scene, equipment)
      scene.instance_eval do
        equip = Event.new do |e|
          if @player.equip?(equipment.equipment_type)
            old_equipment = @player.get_equipment(equipment.equipment_type)
            old_equipment.removed!
          end

          @player.equip(equipment)
          tick
          e.finalize
        end

        equip.set_next(ClearMenuWindowEvent.create(self))
        msg = MessageManager.equip_item(equipment.name)
        equip.set_next(ShowMessageEvent.create(self, msg))
        equip
      end
    end
  end
end

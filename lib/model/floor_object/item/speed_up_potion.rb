module MyDungeonGame
  # 倍速の薬
  class SpeedUpPotion < Potion
    name MessageManager.get('dict.items.speed_up_potion.name')
    note MessageManager.get('dict.items.speed_up_potion.note')

    def message(target)
      MessageManager.speed_up(target.name)
    end

    def speed_up_event(scene, target)
      target.temporary_status_set(:speed_up, 15)
      ShowMessageEvent.create(scene, message(target))
    end

    def effect_event(scene)
      speed_up_event(scene, scene.player)
    end

    def hit_event(scene, thrower, target)
      return Event.new { |e| e.finalize } if thrower.dead?
      first_event = super
      first_event.set_next(speed_up_event(scene, target))
      first_event
    end
  end
end

module MyDungeonGame
  # ワープする薬
  class WarpPotion < Potion
    name MessageManager.get('dict.items.warp_potion.name')
    note MessageManager.get('dict.items.warp_potion.note')

    def message(target)
      MessageManager.warped(target.name)
    end

    def warp_event(scene, target)
      if target.warpable?
        WarpEvent.create(scene, target)
      else
        msg = MessageManager.get(:but_nothing_occured)
        ShowMessageEvent.create(scene, msg)
      end
    end

    def effect_event(scene)
      warp_event(scene, scene.player)
    end

    def hit_event(scene, thrower, target)
      return Event.new { |e| e.finalize } if thrower.dead?
      first_event = super
      first_event.set_next(warp_event(scene, target))
      first_event
    end
  end
end

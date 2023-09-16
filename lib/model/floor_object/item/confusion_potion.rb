module MeiroSeeker
  # 混乱の薬
  class ConfusionPotion < Potion
    name MessageManager.get('dict.items.confusion_potion.name')
    note MessageManager.get('dict.items.confusion_potion.note')

    def message(target)
      MessageManager.confuse(target.name)
    end

    def anti_message(target)
      MessageManager.anti_status(target.name, :confusion)
    end

    def confuse_event(scene, target)
      if target.anti?(:confusion)
        ShowMessageEvent.create(scene, anti_message(target))
      else
        target.temporary_status_set(:confusion, 20)
        ShowMessageEvent.create(scene, message(target))
      end
    end

    def effect_event(scene)
      confuse_event(scene, scene.player)
    end

    def hit_event(scene, thrower, target)
      return Event.new { |e| e.finalize } if thrower.dead?
      first_event = super
      first_event.set_next(confuse_event(scene, target))
      first_event
    end
  end
end

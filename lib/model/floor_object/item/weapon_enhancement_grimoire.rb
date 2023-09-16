module MeiroSeeker
  # 武器強化の魔導書
  # 武器の修正値を+1する
  class WeaponEnhancementGrimoire < Grimoire
    range_type :only_player
    name       MessageManager.get('dict.items.weapon_enhancement_grimoire.name')
    note       MessageManager.get('dict.items.weapon_enhancement_grimoire.note')

    def effect_event(scene)
      weapon = target_characters(scene).weapon
      if weapon
        weapon.origin.calibration += 1
        if weapon.origin.calibration > Equipment::MAX_CALIBRATION
          weapon.origin.calibration = Equipment::MAX_CALIBRATION
        end
        # TODO: 呪われている場合は呪いの解除
        effect = WeaponEnhancementEffect.new
        first_event = effect.event
        msg = MessageManager.get(:weapon_enhanced)
        first_event.set_next(ShowMessageEvent.create(scene, msg))
        first_event
      else
        msg = MessageManager.get(:but_nothing_occured)
        ShowMessageEvent.create(scene, msg)
      end
    end
  end
end

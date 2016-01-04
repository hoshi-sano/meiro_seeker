module MyDungeonGame
  # 盾強化の魔導書
  # 盾の修正値を+1する
  class ShieldEnhancementGrimoire < Grimoire
    range_type :only_player
    name       MessageManager.get('dict.items.shield_enhancement_grimoire.name')
    note       MessageManager.get('dict.items.shield_enhancement_grimoire.note')

    def effect_event(scene)
      shield = target_characters(scene).shield
      if shield
        shield.origin.calibration += 1
        if shield.origin.calibration > Equipment::MAX_CALIBRATION
          shield.origin.calibration = Equipment::MAX_CALIBRATION
        end
        # TODO: 呪われている場合は呪いの解除
        # TODO: エフェクト
        msg = MessageManager.get(:shield_enhanced)
        ShowMessageEvent.create(scene, msg)
      else
        msg = MessageManager.get(:but_nothing_occured)
        ShowMessageEvent.create(scene, msg)
      end
    end
  end
end

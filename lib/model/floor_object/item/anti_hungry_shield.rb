module MeiroSeeker
  # 腹が減りにくくなる盾
  class AntiHungryShield < Shield
    name MessageManager.get('dict.items.anti_hungry_shield.name')
    note MessageManager.get('dict.items.anti_hungry_shield.note')
    equipped_image_path File.join(ROOT, 'data', 'shield_effect.png')
    base_strength 2
    extra_effect :anti_hungry
  end
end

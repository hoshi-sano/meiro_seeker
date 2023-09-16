module MeiroSeeker
  # 腹が減りやすくなる盾
  class HungryShield < Shield
    name MessageManager.get('dict.items.hungry_shield.name')
    note MessageManager.get('dict.items.hungry_shield.note')
    equipped_image_path File.join(ROOT, 'data', 'shield_effect.png')
    base_strength 12
    extra_effect :hungry
  end
end

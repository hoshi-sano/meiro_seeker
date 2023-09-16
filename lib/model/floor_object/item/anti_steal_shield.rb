module MeiroSeeker
  # アイテムを盗まれなくなる盾
  class AntiStealShield < Shield
    name MessageManager.get('dict.items.anti_steal_shield.name')
    note MessageManager.get('dict.items.anti_steal_shield.note')
    equipped_image_path File.join(ROOT, 'data', 'shield_effect.png')
    base_strength 4
    extra_effect :anti_steal
  end
end

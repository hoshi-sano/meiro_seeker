module MyDungeonGame
  # 鉄の盾
  class IronShield < Shield
    type :item
    name MessageManager.get('dict.items.iron_shield.name')
    note MessageManager.get('dict.items.iron_shield.note')
    image IMAGES[:shield]
    equipped_image_path File.join(ROOT, 'data', 'shield_effect.png')
    base_strength 5
  end
end

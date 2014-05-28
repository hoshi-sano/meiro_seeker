module MyDungeonGame
  # サーベル
  class Sabel < Weapon
    type :item
    name MessageManager.get('dict.items.sabel.name')
    note MessageManager.get('dict.items.sabel.note')
    image IMAGES[:weapon]
    base_strength 5
  end
end

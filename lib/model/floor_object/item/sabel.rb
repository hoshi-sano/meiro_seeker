module MeiroSeeker
  # サーベル
  class Sabel < Weapon
    name MessageManager.get('dict.items.sabel.name')
    note MessageManager.get('dict.items.sabel.note')
    # equipped_image_pathは暫定
    equipped_image_path File.join(ROOT, 'data', 'weapon_effect.png')
    base_strength 5
  end
end

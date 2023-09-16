module MeiroSeeker
  # ゴースト系に強い武器
  class GhostBuster < Weapon
    name MessageManager.get('dict.items.ghost_buster.name')
    note MessageManager.get('dict.items.ghost_buster.note')
    # equipped_image_pathは暫定
    equipped_image_path File.join(ROOT, 'data', 'weapon_effect.png')
    base_strength 4
    extra_effect :ghost_buster
  end
end

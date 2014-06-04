module MyDungeonGame
  # 通常弾
  class NormalBullet < Bullet
    type :item
    name MessageManager.get('dict.items.normal_bullet.name')
    note MessageManager.get('dict.items.normal_bullet.note')
    image IMAGES[:weapon] # 暫定
    # equipped_image_pathはなし
    base_strength 1
  end
end

module MyDungeonGame
  # 肉まん
  # 満腹度回復系
  class NikuMan < Item
    type :item
    name MessageManager.get('dict.items.niku_man.name')
    image IMAGES[:manju]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :stomach, 100, 10)
    end
  end
end

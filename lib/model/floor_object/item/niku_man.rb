module MyDungeonGame
  # 肉まん
  # 満腹度回復系
  class NikuMan < Item
    name MessageManager.get('items.name.niku_man')

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :stomach, 100, 10)
    end
  end
end

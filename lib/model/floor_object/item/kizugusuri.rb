module MyDungeonGame
  class Kizugusuri < Item
    type :item
    name MessageManager.get('items.name.kizugusuri')
    image IMAGES[:potion]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, 25, 2)
    end
  end
end

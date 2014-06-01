module MyDungeonGame
  class Kizugusuri < Item
    type :item
    name MessageManager.get('dict.items.kizugusuri.name')
    note MessageManager.get('dict.items.kizugusuri.note')
    image IMAGES[:potion]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, 25, 1)
    end

    def order
      ORDER[:potion]
    end
  end
end

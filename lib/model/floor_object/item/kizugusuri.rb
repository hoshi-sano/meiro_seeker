module MyDungeonGame
  class Kizugusuri < Item
    name MessageManager.get('items.name.kizugusuri')

    def effect_event
      ParamRecoverEvent.create(@scene, @scene.player, :hp, 25, 2)
    end
  end
end

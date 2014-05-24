module MyDungeonGame
  # 回復の薬
  # HP回復系
  class KaifukuNoKusuri < Item
    name MessageManager.get('items.name.kaifuku_no_kusuri')

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, 100, 4)
    end
  end
end

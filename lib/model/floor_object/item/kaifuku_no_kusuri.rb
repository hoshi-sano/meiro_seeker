module MyDungeonGame
  # 回復の薬
  # HP回復系
  class KaifukuNoKusuri < Item
    type :item
    name MessageManager.get('dict.items.kaifuku_no_kusuri.name')
    note MessageManager.get('dict.items.kaifuku_no_kusuri.note')
    image IMAGES[:potion]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, 100, 4)
    end

    def order
      ORDER[:potion]
    end
  end
end

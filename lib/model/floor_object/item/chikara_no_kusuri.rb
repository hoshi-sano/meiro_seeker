module MyDungeonGame
  # 力の薬
  # 力の回復・上昇系
  class ChikaraNoKusuri < Item
    type :item
    name MessageManager.get('dict.items.chikara_no_kusuri.name')
    image IMAGES[:potion]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :power, 1, 1)
    end
  end
end

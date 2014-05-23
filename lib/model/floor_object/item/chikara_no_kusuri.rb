module MyDungeonGame
  # 力の薬
  # 力の回復・上昇系
  class ChikaraNoKusuri < Item
    name MessageManager.get('items.name.chikara_no_kusuri')

    def effect_event
      ParamRecoverEvent.create(@scene, @scene.player, :power, 1, 1)
    end
  end
end

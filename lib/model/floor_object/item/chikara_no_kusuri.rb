module MeiroSeeker
  # 力の薬
  # 力の回復・上昇系
  class ChikaraNoKusuri < Potion
    name MessageManager.get('dict.items.chikara_no_kusuri.name')
    note MessageManager.get('dict.items.chikara_no_kusuri.note')

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :power, 1, 1)
    end
  end
end

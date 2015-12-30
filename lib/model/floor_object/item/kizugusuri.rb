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

    # 投擲した場合のイベント
    def hit_event(scene, thrower, target)
      # TODO: targetが敵かプレイヤーか判定(敵の場合は最大値上昇はなし)
      # TODO: 敵がアンデッド系だった場合の処理
      e = super
      e.set_next(ParamRecoverEvent.create(scene, target, :hp, 25, 1))
      e
    end
  end
end

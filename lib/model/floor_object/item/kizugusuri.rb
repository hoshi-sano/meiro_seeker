module MyDungeonGame
  # 傷薬
  # HP回復系
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

    # TODO: 回復の薬との共通化
    # 投擲した場合のイベント
    def hit_event(scene, thrower, target)
      with_death_check(scene, thrower, target) do |scene, thrower, target|
        e = super
        if target.type == :player
          # プレイヤーの場合はHPが25ポイント回復
          # HPが満タンだった場合はHPの最大値が1上昇
          e.set_next(ParamRecoverEvent.create(scene, target, :hp, 25, 1))
        elsif target.included?(:undead)
          # アンデッド系の場合はダメージ
          target.hp -= 25
          e.set_next(DamageEvent.create(scene, target, 25))
        else
          # モブの場合はHPが25ポイント回復、HP最大値上昇はなし
          e.set_next(ParamRecoverEvent.create(scene, target, :hp, 25))
        end
        e
      end
    end
  end
end

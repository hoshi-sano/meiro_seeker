module MyDungeonGame
  # 回復の薬
  # HP回復系
  class KaifukuNoKusuri < Item
    type :item
    name MessageManager.get('dict.items.kaifuku_no_kusuri.name')
    note MessageManager.get('dict.items.kaifuku_no_kusuri.note')
    image IMAGES[:potion]

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, 100, 2)
    end

    def order
      ORDER[:potion]
    end

    # TODO: 傷薬との共通化
    # 投擲した場合のイベント
    def hit_event(scene, thrower, target)
      with_death_check(scene, thrower, target) do |scene, thrower, target|
        e = super
        if target.type == :player
          # プレイヤーの場合はHPが100ポイント回復
          # HPが満タンだった場合はHPの最大値が2上昇
          e.set_next(ParamRecoverEvent.create(scene, target, :hp, 100, 2))
        elsif target.included?(:undead)
          # アンデッド系の場合はダメージ
          target.hp -= 100
          e.set_next(DamageEvent.create(scene, target, 100))
        else
          # モブの場合はHPが100ポイント回復、HP最大値上昇はなし
          e.set_next(ParamRecoverEvent.create(scene, target, :hp, 100))
        end
        e
      end
    end
  end
end

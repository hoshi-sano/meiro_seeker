module MyDungeonGame
  # 雷鳴の魔導書
  # 部屋全体に25〜45ダメージ
  # 通路で使った場合は周囲8マスにダメージ
  class ThunderGrimoire < Grimoire
    range_type :room
    name       MessageManager.get('dict.items.thunder_grimoire.name')
    note       MessageManager.get('dict.items.thunder_grimoire.note')

    def calc_damage
      25 + DungeonManager.randomizer.rand(20)
    end

    def effect_event(scene)
      player = scene.player
      # TODO: エフェクト
      first_event = nil
      target_characters(scene).each do |t|
        with_death_check(scene, player, t) do |scene, player, t|
          # 1体ごとにランダムのダメージを計算
          damage = calc_damage
          t.hp -= damage
          de = DamageEvent.create(scene, t, damage)
          me = ShowMessageEvent.create(scene, MessageManager.to_damage(damage))
          de.set_next(me)
          if first_event
            first_event.set_next(de)
          else
            first_event = de
          end
          first_event
        end
      end
      first_event
    end
  end
end

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
      show_map = !scene.instance_variable_get(:@hide_radar_map)
      # アニメーション表示のためにレーダーマップを非表示にする
      first_event = Event.new do |e|
        scene.instance_variable_set(:@hide_radar_map, true) if show_map
        e.finalize
      end
      # 落雷のアニメーション
      thunder = ThunderEffect.new
      first_event.set_next(thunder.surround_player_event_small(player))
      if player.in_room?
        5.times { first_event.set_next(Event.new { |e| e.finalize }) } # wait
        first_event.set_next(Event.new { |e| thunder.rewind; e.finalize })
        first_event.set_next(thunder.surround_player_event_big(player))
      end
      # 非表示にしたレーダーマップを再表示
      map_rollback = Event.new do |e|
        scene.instance_variable_set(:@hide_radar_map, false) if show_map
        e.finalize
      end
      first_event.set_next(map_rollback)
      # ダメージ処理
      target_characters(scene).each do |t|
        with_death_check(scene, player, t) do |scene, player, t|
          # 1体ごとにランダムのダメージを計算
          damage = calc_damage
          t.hp -= damage
          de = DamageEvent.create(scene, t, damage)
          me = ShowMessageEvent.create(scene, MessageManager.to_damage(damage))
          de.set_next(me)
          first_event.set_next(de)
          first_event
        end
      end
      first_event
    end
  end
end

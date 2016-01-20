module MyDungeonGame
  # 天眼の魔導書
  # ダンジョンのマップを見通す
  class LightGrimoire < Grimoire
    name MessageManager.get('dict.items.light_grimoire.name')
    note MessageManager.get('dict.items.light_grimoire.note')

    def effect_event(scene)
      # 光が広がるアニメーション
      animation = LightEffect.vertical_light_event

      # メッセージ表示
      msg = MessageManager.get(:light_shines)
      animation.set_next(ShowMessageEvent.create(scene, msg))

      # 効果
      effect = Event.new do |e|
        scene.instance_eval do
          # フロアとオブジェクトを探知済みにする
          @floor.each_tile { |_, _, tile| tile.searched! }
          @floor_objects.each { |o| o.searched! }
          # 1フロアの間のみ透視能力を付与
          @player.floor_permanent_status_set(:second_sight)
        end
        e.finalize
      end
      animation.set_next(effect)

      animation
    end
  end
end

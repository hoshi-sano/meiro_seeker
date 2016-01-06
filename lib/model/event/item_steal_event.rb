module MyDungeonGame
  # アイテムを盗むイベント
  # TODO: お金を盗むのも同じイベントで処理できるようにする
  module ItemStealEvent
    module_function

    def create(scene, thief, target, opts={})
      scene.instance_eval do
        first_event = Event.new(if_alive: thief) do |e|
          # 自身を含むすべてのモブが移動等の動作を完了するまで
          # 盗み演出を開始しない
          if @mobs.any? { |mob| mob.updating? }
            @player.update
            update_mobs
            move_mobs
          else
            e.finalize
          end
        end

        thief_event = Event.new(if_alive: thief) do |e|
          items = target.stealable_items
          if items.any?
            target_item = items[DungeonManager.randomizer.rand(items.size)]
            target.items.delete(target_item)
            # 盗み演出
            # TODO: 攻撃アニメではなく特殊技能アニメを使う
            e.set_next(AttackEvent.create(self, thief, target))
            msg = MessageManager.stolen_item(target_item.name)
            msg_event = ShowMessageEvent.create(self, msg)
            e.set_next(msg_event)
            e.set_next(WarpEvent.create(self, thief))
            thief.floor_permanent_status_set(:escape) if opts[:escape]
            # TODO: 高速移動可能にする if opts[:speed_up]
          else
            # 盗めるアイテムがない場合は様子見のみ行う
            msg = MessageManager.wait_and_see(thief.name)
            msg_event = ShowMessageEvent.create(self, msg)
            e.set_next(msg_event)
          end
          e.finalize
        end
        first_event.set_next(thief_event)
        first_event
      end
    end
  end
end

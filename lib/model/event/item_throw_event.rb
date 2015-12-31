module MyDungeonGame
  module ItemThrowEvent
    module_function

    def create(scene, thrower, item)
      scene.instance_eval do
        player = (thrower.type == :player)
        if player
          first_event = ClearMenuWindowEvent.create(scene)
        else
          # throwerが既に死んでいる場合はこのイベントを実行しない
          first_event = Event.new(if_alive: thrower) do |e|
            # 投擲者自身を含むすべてのモブが移動等の動作を完了するまで
            # 投擲演出を開始しない
            if @mobs.any? { |mob| mob.updating? }
              @player.update
              update_mobs
              move_mobs
            else
              e.finalize
            end
          end
        end

        throw_item = Event.new do |e|
          if player && thrower.items.delete(item)
            # プレイヤーのアイテム一覧から投げる場合
            item.removed! if item.equipped?
          elsif @floor_objects.delete(item)
            # 落ちているアイテムから投げる場合
            @floor[item.x, item.y].clear_object
          end

          # 最初に当たった者をtargetとする
          dist = 0
          step = thrower.get_forward_step
          target = nil
          dest_tile = nil
          THROW_RANGE.times do |i|
            dist = i + 1
            item.x = thrower.x + step[0] * dist
            item.y = thrower.y + step[1] * dist
            dest_tile = @floor[item.x, item.y]

            if !dest_tile.walkable?
              # 壁の場合は1マス手前に落ちる
              item.x -= step[0]
              item.y -= step[1]
              dest_tile = @floor[item.x, item.y]
              break
            elsif dest_tile.any_one?
              target = dest_tile.character
              break
            end
          end

          # TODO: アイテム投げ専用の演出イベントを作る(?)
          # TODO: 敵の投げ演出イベントを使う
          # 投げ演出
          e.set_next(PlayerAttackEvent.create(self)) if player
          # アイテム飛び演出
          dist.times do |i|
            fly_e = Event.new do |e|
              x = thrower.x + step[0] * i
              y = thrower.y + step[1] * i
              args = [x * TILE_WIDTH,
                      y * TILE_HEIGHT - THROW_ALTITUDE, item, :effect]
              OutputManager.reserve_draw(*args)
              e.finalize
            end
            e.set_next(fly_e)
          end

          hit = DungeonManager.randomizer.rand(100) < THROW_ACCURACY
          if target.nil? || !hit
            # アイテム落下処理
            drop_e = Event.new do |e|
              if drop(item, item.x, item.y)
                msg = MessageManager.drop_item(item.name)
              else
                msg = MessageManager.lost_item(item.name)
              end
              e.set_next(ShowMessageEvent.create(self, msg))
              e.finalize
            end
            e.set_next(drop_e)
          else
            # アイテムヒット処理
            e.set_next(item.hit_event(self, thrower, target))
          end

          e.finalize
        end
        first_event.set_next(throw_item)

        if player
          # ターンの消費とモブのアクション
          tick_event = Event.new do |e|
            tick
            activate_mobs
            update_mobs
            move_mobs
            @do_action = false
            e.finalize
          end
          first_event.set_next(tick_event)
        end

        first_event
      end
    end
  end
end

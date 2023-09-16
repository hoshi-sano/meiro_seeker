module MeiroSeeker
  # 射撃イベント
  # ItemThrowEventとほぼ同じ
  module ShotEvent
    module_function

    def create(scene, thrower, item)
      scene.instance_eval do
        clear_menu = ClearMenuWindowEvent.create(scene)

        shot = Event.new do |e|
          # 残弾数が1なら消滅する
          if item.calibration == 1
            if @player.items.delete(item)
              # プレイヤーのアイテム一覧から射つ場合
              item.removed! if item.equipped?
            else
              # 落ちているアイテムから射つ場合
              @floor_objects.delete(item)
              @floor[item.x, item.y].clear_object
            end
          end

          item = item.divide(1)

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

          # TODO: 射撃専用の演出イベントを利用する
          # 暫定的に投げ演出
          e.set_next(PlayerAttackEvent.create(self))
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
        clear_menu.set_next(shot)

        # ターンの消費とモブのアクション
        tick_event = Event.new do |e|
          tick
          activate_mobs
          update_mobs
          move_mobs
          @do_action = false
          e.finalize
        end
        clear_menu.set_next(tick_event)

        clear_menu
      end
    end
  end
end

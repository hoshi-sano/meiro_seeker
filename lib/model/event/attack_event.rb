module MyDungeonGame
  # モブの直接攻撃演出
  module AttackEvent
    module_function

    def create(scene, attacker, target)
      scene.instance_eval do
        # attackerが既に死んでいる場合はこのイベントを実行しない
        first_event = Event.new(if_alive: attacker) do |e|
          # 攻撃者自身を含むすべてのモブが移動等の動作を完了するまで
          # 攻撃演出を開始しない
          if @mobs.any? { |mob| mob.updating? }
            @player.update
            update_mobs
            move_mobs
          else
            e.finalize
          end
        end


        # step = [target.x - attacker.x, target.y - attacker.y]
        step = attacker.get_forward_step_to_target(target)

        # 攻撃演出をフレーム毎のイベントに細分化したもの
        events = CHARACTER_ATTACK_MOVE_AND_FRAMES.map do |i, frame|
          [step[0] * i, step[1] * i, frame]
        end.map do |cx, cy, frame|
          Event.new(if_alive: attacker) do |e|
            attacker.change_direction_to_object(target) if frame.zero?
            # 攻撃時のエフェクトはダミーを使って描画するため本体は非表示にする
            attacker.hide
            @waiting_update_complete = true
            dummy = attacker.display_dummy
            dummy.attack_frame(frame)
            args = [(attacker.x * TILE_WIDTH) + cx,
                    (attacker.y * TILE_HEIGHT) + cy,
                    dummy, :character]
            OutputManager.reserve_draw(*args)
            e.finalize
          end
        end

        last_event = Event.new(if_alive: attacker) do |e|
          @waiting_update_complete = true
          # 攻撃演出終了時に本体を再表示
          attacker.show
          e.finalize
        end
        events.push(last_event)

        events.each {|e| first_event.set_next(e) }
        first_event
      end
    end
  end
end

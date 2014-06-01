module MyDungeonGame
  # モブの直接攻撃演出
  module AttackEvent
    module_function

    def create(scene, attacker)
      scene.instance_eval do
        step = attacker.get_forward_step
        events = CHARACTER_ATTACK_MOVE_AND_FRAMES.map do |i, frame|
          [step[0] * i, step[1] * i, frame]
        end.map do |cx, cy, frame|
          Event.new do |e|
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

        last_event = Event.new do |e|
          @waiting_update_complete = true
          attacker.show
          e.finalize
        end
        events.push(last_event)

        first_event = events.shift
        events.each {|e| first_event.set_next(e) }
        first_event
      end
    end
  end
end

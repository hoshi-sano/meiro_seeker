module MyDungeonGame
  # モブの直接攻撃演出
  module AttackEvent
    module_function

    def create(scene, attacker)
      scene.instance_eval do
        step = attacker.get_forward_step
        events = [10, 15, 12, 9, 6, 3, 1].map do |i|
          step.map{|v| i * v }
        end.map do |cx, cy|
          Event.new do |e|
            attacker.hide
            @waiting_update_complete = true
            args = [(attacker.x * TILE_WIDTH) + cx,
                    (attacker.y * TILE_HEIGHT) + cy,
                    attacker.display_dummy, :character]
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

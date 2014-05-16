module MyDungeonGame
  # プレイヤーの攻撃演出
  module PlayerAttackEvent
    module_function

    def create(scene)
      scene.instance_eval do
        step = @player.get_forward_step
        events = [10, 15, 12, 9, 6, 3, 1].map do |i|
          step.map{|v| i * v }
        end.map do |cx, cy|
          Event.new do |e|
            @player.hide
            @waiting_update_complete = true
            args = [@player.display_dummy, cx, cy]
            OutputManager.reserve_draw_center_with_calibration(*args)
            e.finalize
          end
        end

        last_event = Event.new do |e|
          @waiting_update_complete = true
          @player.show
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

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
            # プレイヤー本体
            @player.hide
            @waiting_update_complete = true
            args = [@player.display_dummy, cx, cy]
            OutputManager.reserve_draw_center_with_calibration(*args)
            # 装備品
            [@player.weapon, @player.shield].compact.map do |equipment|
              equipment.hide
              args = [equipment.display_dummy, cx, cy]
              OutputManager.reserve_draw_center_with_calibration(*args)
            end
            e.finalize
          end
        end

        last_event = Event.new do |e|
          @waiting_update_complete = true
          # プレイヤー本体
          @player.show
          # 装備品
          [@player.weapon, @player.shield].compact.each do |equipment|
            equipment.show
          end
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

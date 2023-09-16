module MeiroSeeker
  # プレイヤーの攻撃演出
  module PlayerAttackEvent
    module_function

    def create(scene)
      scene.instance_eval do
        step = @player.get_forward_step
        events = CHARACTER_ATTACK_MOVE_AND_FRAMES.map do |i, frame|
          [step[0] * i, step[1] * i, frame]
        end.map do |cx, cy, frame|
          Event.new do |e|
            # プレイヤー本体
            @player.hide
            @waiting_update_complete = true
            dummy = @player.display_dummy
            dummy.attack_frame(frame)
            args = [dummy, cx, cy]
            OutputManager.reserve_draw_center_with_calibration(*args)
            # 装備品
            [@player.weapon, @player.shield].compact.map do |equipment|
              equipment.hide
              dummy = equipment.display_dummy
              dummy.attack_frame(frame)
              args = [dummy, cx, cy]
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

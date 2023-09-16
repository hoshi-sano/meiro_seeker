module MeiroSeeker
  # 入力待ちのイベント
  module WaitInputEvent
    module_function

    def create(scene)
      scene.instance_eval do
        Event.new do |e|
          if !@waiting_update_complete
            handle_input
            activate_mobs
          end
          @player.update
          update_mobs
          move_mobs
          @do_action = false
        end
      end
    end
  end
end

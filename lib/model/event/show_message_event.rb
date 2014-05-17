module MyDungeonGame
  module ShowMessageEvent
    module_function
    def create(scene, message='')
      scene.instance_eval do
        window = MessageWindow.new(message)
        Event.new do |e|
          OutputManager.reserve_draw_message_window(window)
          @player.update
          update_mobs
          move_mobs
          e.finalize if InputManager.push_ok?
        end
      end
    end
  end
end

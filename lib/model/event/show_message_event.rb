module MyDungeonGame
  module ShowMessageEvent
    module_function
    def create(scene, message='')
      scene.instance_eval do
        window = MessageWindow.new
        Event.new do |e|
          # TODO: window.imageがダサいのでなんとかする
          args = [window.image, 0, 170, :window]
          OutputManager.reserve_draw_center_with_calibration(*args)
          @player.update
          update_mobs
          move_mobs
          e.finalize if InputManager.push_ok?
        end
      end
    end
  end
end

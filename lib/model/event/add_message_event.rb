module MyDungeonGame
  module AddMessageEvent
    module_function

    def create(scene, message='')
      scene.instance_eval do
        return if @message_window.nil?

        first = Event.new do |e|
          @message_window.permanence!
          @message_window.message += '>'
          @message_window.message.gsub!(/>>>>/, '')
          #@player.update
          #update_mobs
          #move_mobs
          if InputManager.push_ok?
            @message_window.init_ttl
            e.finalize
          end
        end
        first.set_next(ShowMessageEvent.create(scene, message))
        first
      end
    end
  end
end

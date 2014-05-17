module MyDungeonGame
  module ShowMessageEvent
    module_function

    def create(scene, message='')
      scene.instance_eval do
        window = MessageWindow.new('')

        first = Event.new do |e|
          @message_window = window
          e.finalize
        end

        # メッセージ送りを表現する
        range = 0..(message.length + MESSAGE_SPEED)
        range.step(MESSAGE_SPEED).each do |idx|
          follow_event = Event.new do |e|
            @message_window.message = message[0..idx]
            e.finalize
          end
          first.set_next(follow_event)
        end
        first
      end
    end
  end
end

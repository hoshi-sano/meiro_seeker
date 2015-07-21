module MyDungeonGame
  module TalkEvent
    module_function

    def create(scene, speaker, message, opposite=nil)
      scene.instance_eval do

        first = Event.new do |e|
          if @message_window
            @message_window.init_ttl
            @message_window.clear
          else
            @message_window = MessageWindow.new('')
          end
          e.finalize
        end

        # 話者の方向を話し相手に向ける
        change_direction = Event.new do |e|
          speaker.change_direction_to_object(opposite)
          e.finalize
        end
        first.set_next(change_direction)

        # メッセージの流れを表現する
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

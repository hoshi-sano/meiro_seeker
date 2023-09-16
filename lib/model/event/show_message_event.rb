module MeiroSeeker
  module ShowMessageEvent
    module_function

    def create(scene, message='', options={})
      scene.instance_eval do

        first = Event.new do |e|
          if @message_window
            @message_window.init_ttl
            @message_window.newline!
          else
            @message_window = MessageWindow.new('')
          end
          e.finalize
        end

        # メッセージウィンドウがいっぱいだった場合は
        # 入力があるまで更新しない
        check_full = Event.new do |e|
          if !@message_window.full?
            e.finalize
          else
            @message_window.permanence!
            @message_window.display_next_arrow
            if InputManager.any_key?
              @message_window.init_ttl
              @message_window.remove_arrow
              @message_window.oldest_line_clear!
              e.finalize
            end
          end
        end
        first.set_next(check_full)

        # メッセージの流れを表現する
        range = 0..(message.length + MESSAGE_SPEED)
        range.step(MESSAGE_SPEED).each do |idx|
          follow_event = Event.new do |e|
            @message_window.message = message[0..idx]
            e.finalize
          end
          first.set_next(follow_event)
        end

        # 入力があるまでその他の操作を受け付けず、
        # メッセージも表示したままとする
        if options[:force_wait_input]
          wait_input = Event.new do |e|
            @message_window.newline!
            @message_window.permanence!
            @message_window.display_next_arrow
            if InputManager.any_key?
              @message_window.set_ttl(0)
              e.finalize
            end
          end
          first.set_next(wait_input)
        end

        first
      end
    end
  end
end

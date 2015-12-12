module MyDungeonGame
  module SaveEvent
    module_function

    def create(scene, _break=false)
      scene.instance_eval do
        e = ClearMenuWindowEvent.create(self)

        msg_key =  _break ? :break_playing : :data_saving
        msg = MessageManager.get(msg_key)
        msg_event_1 = ShowMessageEvent.create(self, msg)
        e.set_next(msg_event_1)
        msg = MessageManager.get(:dont_power_off)
        msg_event_2 = ShowMessageEvent.create(self, msg)
        e.set_next(msg_event_2)

        # 入力があるまでその他の操作を受け付けず、
        # メッセージも表示したままとする
        check_input = Event.new do |e|
          @message_window.newline!
          @message_window.permanence!
          @message_window.display_next_arrow
          if InputManager.any_key?
            @message_window.set_ttl(0)
            e.finalize
          end
        end
        e.set_next(check_input)

        save_event = Event.new do |e|
          e.finalize
          if _break
            GeneralManager.save_and_break
          else
            GeneralManager.save
          end
        end

        e.set_next(save_event)
        e
      end
    end
  end
end

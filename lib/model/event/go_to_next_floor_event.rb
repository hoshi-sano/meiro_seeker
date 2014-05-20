module MyDungeonGame
  module GoToNextFloorEvent
    module_function

    def create(scene)
      scene.instance_eval do
        # 暫定版
        # TODO: yes_or_noで「はい/いいえ」を選択可能にする
        # TODO: yes_or_noを別途イベントにする
        yes_or_no = Event.new do |e|
          @message_window ||= MessageWindow.new('')
          @message_window.clear
          @message_window.message = MessageManager.get(:go_to_next?)
          @message_window.permanence!
          @yes_no_window = YesNoWindow.new
          e.finalize
        end

        wait_input = Event.new do |e|
          dy = InputManager.get_y
          # 上下が押されたら「はい/いいえ」を指す矢印の位置を変更
          @yes_no_window.switch(dy) if !(dy.zero?)

          if InputManager.down_ok?
            if @yes_no_window.yes?
              e.set_next_cut_in(Event.new {|e| go_to_next_floor; e.finalize })
            else
              e.set_next_cut_in(Event.new {|e| e.finalize })
            end
            @message_window.set_ttl(0)
            @yes_no_window = nil
            e.finalize
          end
        end
        yes_or_no.set_next(wait_input)

        yes_or_no
      end
    end
  end
end

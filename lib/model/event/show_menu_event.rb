module MyDungeonGame
  # メニューウインドウ表示イベント
  # 選択肢によって発生するイベントに入れ子にすることが可能
  # 複数のメニューウインドウが存在する場合はLIFOで処理する
  module ShowMenuEvent
    module_function

    def create(scene, menu_window, font_type=:regular)
      scene.instance_eval do
        root = Event.new do |e|
          @message_window.set_ttl(0) if @message_window
          @menu_windows.push(menu_window)
          e.finalize
        end

        wait_input = Event.new do |e|
          window = @menu_windows.last
          window.select(*InputManager.get_push_xy)
          if InputManager.push_ok?
            remove_this_window = Event.new do |e|
              @menu_windows.delete(window)
              e.finalize
            end
            e.set_next_cut_in(remove_this_window)
            e.set_next_cut_in(window.get_event)
            e.finalize
          end
        end
        root.set_next(wait_input)

        root
      end
    end
  end
end

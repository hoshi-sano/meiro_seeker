module MyDungeonGame
  # メニューウインドウ表示イベント
  # 選択肢によって発生するイベントに入れ子にすることが可能
  # 複数のメニューウインドウが存在する場合はLIFOで処理する
  module ShowMenuEvent
    module_function

    def create(scene, menu_window, font_type=:regular)
      scene.instance_eval do
        root = Event.new do |e|
          if menu_window.show_status?
            @message_window = StatusWindow.new(@player)
          else
            @message_window.set_ttl(0) if @message_window
          end
          # 未表示ならpush、表示済みなら何もしない。
          # キャンセルで子のウインドウからフォーカスが返ってきたときに
          # 「表示済み」となる
          if !@menu_windows.include?(menu_window)
            @menu_windows.push(menu_window)
          end
          e.finalize
        end

        wait_input = Event.new do |e|
          window = @menu_windows.last
          window.select(*InputManager.get_push_xy)
          if InputManager.push_ok?
            if ne = window.get_event(self)
              e.set_next_cut_in(ne)
            else
              @message_window.set_ttl(0) if window.show_status?
              @menu_windows.delete(window)
              if window = @menu_windows.last
                e.set_next_cut_in(ShowMenuEvent.create(self, window))
              end
            end
            e.finalize
          elsif InputManager.push_cancel?
            @message_window.set_ttl(0) if window.show_status?
            @menu_windows.delete(window)
            if window = @menu_windows.last
              e.set_next_cut_in(ShowMenuEvent.create(self, window))
            end
            e.finalize
          elsif window.is_a?(ItemWindow) && InputManager.push_sort?
            @player.items.sort!
            window.instance_variable_set(:@choices, @player.items)
          end
        end
        root.set_next(wait_input)

        root
      end
    end
  end
end

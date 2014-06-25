module MyDungeonGame
  # キーコンフィグウィンドウ表示イベント
  module ShowKeyConfigWindowEvent
    module_function

    def create(scene, window, font_type=:regular)
      scene.instance_eval do
        root = Event.new do |e|
          @menu_windows.push(window)
          e.finalize
        end

        wait_input = Event.new do |e|
          window.select(*InputManager.get_push_xy)
          if window.configurable? && got_key = InputManager.get_pushed_key
            window.set(got_key)
          elsif InputManager.push_ok? && window.selectable?
            # 「変更取り消し」「デフォルトに戻す」「適用」のいずれかを
            # 選択した場合。「適用」が成功した場合のみtrueを返し、キー
            # コンフィグ設定ウィンドウを閉じる。
            if window.get_event(self)
              @message_window.set_ttl(0) if window.show_status?
              @menu_windows.delete(window)
              if window = @menu_windows.last
                e.set_next_cut_in(ShowMenuEvent.create(self, window))
              end
              e.finalize
            end
          end
        end
        root.set_next(wait_input)

        root
      end
    end
  end
end

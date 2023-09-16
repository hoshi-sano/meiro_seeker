module MeiroSeeker
  # アイテム説明ウインドウ表示イベント
  module ShowItemNoteEvent
    module_function

    def create(scene, item, font_type=:regular)
      scene.instance_eval do
        item_menu_window = ItemNoteWindow.new(item)
        show = Event.new do |e|
          @menu_windows << item_menu_window
          e.finalize
        end

        wait_input = Event.new do |e|
          if InputManager.push_ok? || InputManager.push_cancel?
            @menu_windows.delete(item_menu_window)
            if window = @menu_windows.last
              e.set_next_cut_in(ShowMenuEvent.create(self, window))
            end
            e.finalize
          end
        end
        show.set_next(wait_input)

        show
      end
    end
  end
end

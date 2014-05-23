module MyDungeonGame
  class ItemWindow < BaseMenuWindow
    position WINDOW_POSITION[:item]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      return if @choices.size.zero?
      # TODO: 2ページ目に対応する
      @select += y
      @select = @select % @choices.size
    end

    def get_event
      return if @choices.size.zero?
      @choices[@select].menu_event
    end

    def choice_to_text(choice)
      choice.name
    end

    def text
      return MessageManager.get(:no_item) if @choices.size.zero?
      super
    end
  end
end

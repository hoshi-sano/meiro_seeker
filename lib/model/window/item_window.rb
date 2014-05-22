module MyDungeonGame
  class ItemWindow < BaseMenuWindow
    position WINDOW_POSITION[:item]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      # TODO: 2ページ目に対応する
      @select += y
      @select = @select % @choices.size
    end

    def get_event
      @choices[@select].event
    end

    def choice_to_text(choice)
      choice.name
    end
  end
end

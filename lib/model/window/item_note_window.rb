module MeiroSeeker
  # アイテムの説明表示用ウインドウ
  class ItemNoteWindow < MessageWindow
    bg_image ViewProxy.rect(WINDOW_SIZE[:item_note],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:item_note])

    attr_reader :x, :y, :show_status

    def initialize(item, font_type=:regular)
      super(item.note, nil, font_type)
      # メッセージが流れない(アニメーションしない)ように
      self.newline!
      self.permanence!
      @x = WINDOW_POSITION[:item_note][0]
      @y = WINDOW_POSITION[:item_note][1]
      @show_status = true
    end

    def text_position
      [@x + BaseMenuWindow::PADDING, @y + BaseMenuWindow::PADDING]
    end
  end
end

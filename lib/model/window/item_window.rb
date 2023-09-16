module MeiroSeeker
  class ItemWindow < BaseMenuWindow
    position WINDOW_POSITION[:item]
    bg_image ViewProxy.rect(WINDOW_SIZE[:item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    MAX_LINE = 10
    MAX_PAGE = PORTABLE_ITEM_NUMBER / MAX_LINE

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      return if @choices.size.zero? || (x + y).zero?
      page = @select / MAX_LINE
      idx  = @select % MAX_LINE
      page_max_idx = [@choices.size - (page * MAX_LINE), MAX_LINE].min - 1

      # 左右でページ切り替え(ループ)
      page += x
      page = page % ((@choices.size / MAX_LINE) + 1)
      # 上下でカーソル移動(ループ)
      idx += y
      idx = idx % (page_max_idx + 1)

      @select = (page * MAX_LINE) + idx
      @select = @choices.size - 1 if @select >= @choices.size
    end

    def get_event(scene)
      return if @choices.size.zero?
      @choices[@select].menu_event(scene)
    end

    def choice_to_text(choice)
      choice.display_name
    end

    def text
      return MessageManager.get(:no_item) if @choices.size.zero?
      res = []
      if @select < MAX_LINE
        @choices[0..(MAX_LINE-1)].each_with_index do |choice, idx|
          arrow = (@select == idx) ? '>' : ' '
          res << "#{arrow} #{choice_to_text(choice)}"
        end
      else
        @choices[MAX_LINE..-1].each_with_index do |choice, idx|
          arrow = (@select == (idx + MAX_LINE)) ? '>' : ' '
          res << "#{arrow} #{choice_to_text(choice)}"
        end
      end
      if @choices.size > MAX_LINE
        if @select < MAX_LINE
          arrow = '   >>>'
        else
          arrow = '<<<   '
          (PORTABLE_ITEM_NUMBER - @choices.size).times { res << ' ' }
        end
        res << sprintf("%28s", arrow)
      end
      join_choices(res)
    end
  end
end

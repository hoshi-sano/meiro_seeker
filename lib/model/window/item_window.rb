module MyDungeonGame
  class ItemWindow < BaseMenuWindow
    position WINDOW_POSITION[:item]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    MAX_LINE = 10

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      return if @choices.size.zero? || (x + y).zero?
      if !x.zero? && @choices.size > MAX_LINE
        if @select < MAX_LINE
          @select += x.abs * MAX_LINE
          @select = (@choices.size - 1) if @select > @choices.size
        else
          @select -= x.abs * MAX_LINE
        end
      end
      @select += y
      @select = @select % @choices.size
    end

    def get_event(scene)
      return if @choices.size.zero?
      @choices[@select].menu_event(scene)
    end

    def choice_to_text(choice)
      choice.name
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

module MyDungeonGame
  class MenuWindow < BaseWindow
    bg_image ViewProxy.rect(*WINDOW_SIZE[:menu],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    PADDING = 10
    CHOICE_WIDTH = 90

    attr_reader   :x, :y, :reader
    attr_accessor :select

    def initialize(x, y, choices, font_type=:regular)
      super(font_type)
      @x = x || 50
      @y = y || 100
      @choices = choices
      @select = 0
    end

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      current_x, current_y = @select % 2, @select / 2
      next_x = (current_x + x.abs) % 2
      next_y = (current_y + y.abs) % 2
      @select = next_x + next_y * 2
    end

    def get_event
      @choices.values[@select]
    end

    def text
      res = []
      @choices.keys.each_with_index do |key, idx|
        arrow = (@select == idx) ? '>' : ' '
        res << [arrow, key].join(' ')
      end

      [[res[0], res[1]].join("\n"), [res[2], res[3]].join("\n")]
    end

    def left_text_position
      [self.x + PADDING, self.y + PADDING]
    end

    def right_text_position
      [self.x + PADDING + CHOICE_WIDTH, self.y + PADDING]
    end
  end
end

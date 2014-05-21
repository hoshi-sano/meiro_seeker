module MyDungeonGame
  class ItemWindow < BaseWindow
    bg_image ViewProxy.rect(*WINDOW_SIZE[:item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    PADDING = 10

    attr_reader   :x, :y
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
      @select += y
      @select = @select % @choices.size
    end

    def get_event
      @choices[@select].event
    end

    def text
      res = []
      @choices.each_with_index do |item, idx|
        arrow = (@select == idx) ? '>' : ' '
        res << "#{arrow} #{item.name}"
      end
      res.join("\n")
    end

    def text_position
      [self.x + PADDING, self.y + PADDING]
    end
  end
end

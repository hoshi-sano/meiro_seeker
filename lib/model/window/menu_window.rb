module MyDungeonGame
  class BaseMenuWindow < BaseWindow
    class << self
      def position(val)
        @x, @y = *val
      end

      def default_x
        @x
      end

      def default_y
        @y
      end

      def show_status(bool)
        @show_status = bool
      end

      def show_status?
        !!@show_status
      end
    end

    PADDING = 10

    attr_reader   :x, :y
    attr_accessor :select

    def initialize(choices, x=nil, y=nil, font_type=:regular)
      super(font_type)
      @x = x || self.class.default_x
      @y = y || self.class.default_y
      @choices = choices
      @select = 0
    end

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      @select += y
      @select = @select % @choices.size
    end

    # @choicesのvalueにはcallするとEventが生成されるものが入っている
    # ことを想定
    def get_event
      @choices.values[@select].call
    end

    def text
      res = []
      @choices.each_with_index do |choice, idx|
        arrow = (@select == idx) ? '>' : ' '
        res << "#{arrow} #{choice_to_text(choice)}"
      end
      join_choices(res)
    end

    # choiceをハッシュの一要素の配列[key, value]と想定
    def choice_to_text(choice)
      choice[0]
    end

    def join_choices(choices)
      choices.join("\n")
    end

    def text_position
      [self.x + PADDING, self.y + PADDING]
    end

    def show_status?
      self.class.show_status?
    end
  end

  class MainMenuWindow < BaseMenuWindow
    position WINDOW_POSITION[:menu]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:menu],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    CHOICE_WIDTH = 90

    # 入力に応じてカーソルの位置を決める
    def select(x, y)
      current_x, current_y = @select / 2, @select % 2
      next_x = (current_x + x.abs) % 2
      next_y = (current_y + y.abs) % 2
      @select = next_x * 2 + next_y
    end

    def join_choices(choices)
      ["#{choices[0]}  #{choices[2]}",
       "#{choices[1]}  #{choices[3]}"].join("\n")
    end
  end
end

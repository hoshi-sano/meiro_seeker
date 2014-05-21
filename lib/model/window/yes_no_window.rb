module MyDungeonGame
  class YesNoWindow < BaseWindow
    bg_image ViewProxy.rect(*WINDOW_SIZE[:yes_no],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    YES = -1
    NO  = 1

    def initialize(yes=nil, no=nil, font_type=:regular)
      super(font_type)
      @yes = yes || MessageManager.get(:yes)
      @no  = no  || MessageManager.get(:no)
      @select = YES
    end

    def switch(val=nil)
      @select = val || -@select
    end

    def yes?
      @select == YES
    end

    def no?
      @select == NO
    end

    def text
      hoge = self.yes? ? [">", " "] : [" ", ">"]
      "#{hoge[0]} #{@yes}\n#{hoge[1]} #{@no}"
    end
  end
end

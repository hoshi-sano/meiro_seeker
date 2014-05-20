module MyDungeonGame
  class YesNoWindow
    class << self
      def bg_image(image)
        @image = image
      end

      def image
        @image
      end
    end

    YES = -1
    NO  = 1

    bg_image ViewProxy.rect(*WINDOW_SIZE[:yes_no],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    attr_reader :font_type, :image

    # TODO: ベースとなるWindowクラスを作る
    def initialize(yes=nil, no=nil, font_type=:regular)
      @yes = yes || MessageManager.get(:yes)
      @no  = no  || MessageManager.get(:no)
      @font_type = font_type
      @image = self.class.image
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

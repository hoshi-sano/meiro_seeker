module MeiroSeeker
  class MessageWindow < BaseWindow
    bg_image ViewProxy.rect(*WINDOW_SIZE[:message],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    TTL = 100
    FULL_LINE_NUMBER = 3
    ARROW_FLASH_INTERVAL = 15

    attr_accessor :message

    def initialize(message, speaker=nil, font_type=:regular)
      super(font_type)
      @message = message
      @past_messages = []
      @speaker = speaker
      @ttl = TTL
    end

    def text
      return '' if @past_messages.empty? && @message.nil?

      res = @past_messages.join("\n")
      res += "\n" if !res.empty?
      res += @message if @message
      res
    end

    def clear
      @past_messages.clear
      @message.clear
    end

    def display_next_arrow
      latest = @past_messages.last
      if @arrow_flash_interval.nil?
        latest.concat('>')
      end
      @arrow_flash_interval ||= ARROW_FLASH_INTERVAL
      @arrow_flash_interval -= 1
      if @arrow_flash_interval <= 0
        latest.concat('>')
        latest.gsub!(/>>/, '')
        @arrow_flash_interval = ARROW_FLASH_INTERVAL
      end
    end

    def remove_arrow
      @past_messages.last.gsub!(/>/, '')
      @arrow_flash_interval = nil
    end

    def newline!
      return if @message.nil?
      @past_messages << @message
      @message = nil
    end

    def oldest_line_clear!
      @past_messages.shift
    end

    def full?
      @past_messages.size >= FULL_LINE_NUMBER
    end

    def set_ttl(val)
      @ttl = val
    end

    def init_ttl
      @ttl = TTL
    end

    def tick
      return if permanent?
      @ttl -= 1
    end

    def permanence!
      @ttl = -1
    end

    def permanent?
      @ttl < 0
    end

    def alive?
      @ttl != 0
    end
  end
end

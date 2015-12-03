module MyDungeonGame
  # イベント処理を管理するクラス
  class EventManager
    attr_reader :regular_event, :cut_in_event

    def initialize(regular_event)
      @regular_event = regular_event
    end

    def has_cut_in_event?
      !!@cut_in_event
    end

    def do_event
      e = @cut_in_event || @regular_event
      e.call
      if e.finalized
        next_event = e.shift_next
        if next_event
          next_event.set_next(e.next_events)
          @cut_in_event = next_event
        else
          @cut_in_event = nil
        end
      end
    end

    def set_regular_event(event)
      if event.kind_of?(Event)
        @regular_event = event
        true
      else
        false
      end
    end

    def set_cut_in_event(event)
      if event.kind_of?(Event)
        if @cut_in_event
          @cut_in_event.set_next(event)
        else
          @cut_in_event = event
        end
        true
      else
        false
      end
    end
  end
end

module MyDungeonGame
  class Event
    attr_reader :next_events, :finalized

    def initialize(options={}, &block)
      @options = options
      @regular_action = block
      @next_events = []
      @finalized = false
    end

    def call
      # TODO: loggerを使う
      puts "WARN: finalized Event called - #{self}" if @finalized
      if @options[:if_alive] && @options[:if_alive].completely_removed?
        finalize
        return
      end
      @regular_action.call(self)
    end

    def set_finalize_action(idx=nil, &block)
      if idx
        @next_events[idx].instance_variable_set(:@finalize_action, block)
      else
        @finalize_action = block
      end
    end

    def finalize
      @finalize_action.call(self) if @finalize_action
      @finalized = true
    end

    def shift_next
      @next_events.shift
    end

    def set_next(event)
      if event.kind_of?(Event)
        @next_events << event
        true
      elsif event.kind_of?(Array)
        event.each {|e| self.set_next(e) }
        true
      else
        false
      end
    end

    def set_next_cut_in(event)
      if event.kind_of?(Event)
        @next_events.unshift(event)
        true
      elsif event.kind_of?(Array)
        @next_events.unshift(event).flatten!
        true
      else
        false
      end
    end
  end

  class EventPacket
    def initialize(e_module, *args)
      @module = e_module
      @args = args
    end

    def unpack(scene)
      @module.create(*@args.unshift(scene))
    end
  end
end

# load event dir
here = File.dirname(File.expand_path(__FILE__))
event_dir = File.join(here, "event")
Dir.entries(event_dir).each do |fname|
  if fname =~ /\.rb$/
    require File.join(event_dir, fname)
  end
end

module MyDungeonGame
  class Event
    attr_reader :next_events, :finalized

    def initialize(&block)
      @regular_action = block
      @next_events = []
      @finalized = false
    end

    def call
      @regular_action.call(self)
    end

    def set_finalize_action(&block)
      @finalize_action = block
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

require 'event/wait_input_event'
require 'event/attack_event'
require 'event/player_attack_event'
require 'event/move_event'
require 'event/damage_event'
require 'event/dead_event'
require 'event/show_message_event'
require 'event/player_level_up_event'
require 'event/yes_no_event'
require 'event/go_to_next_floor_event'

module MeiroSeeker
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

require_remote "lib/model/event/attack_event.rb"
require_remote "lib/model/event/clear_menu_window_event.rb"
require_remote "lib/model/event/damage_event.rb"
require_remote "lib/model/event/dead_event.rb"
require_remote "lib/model/event/equip_event.rb"
require_remote "lib/model/event/go_to_next_floor_event.rb"
require_remote "lib/model/event/item_steal_event.rb"
require_remote "lib/model/event/item_throw_event.rb"
require_remote "lib/model/event/move_event.rb"
require_remote "lib/model/event/param_recover_event.rb"
require_remote "lib/model/event/player_attack_event.rb"
require_remote "lib/model/event/player_level_up_event.rb"
require_remote "lib/model/event/put_item_event.rb"
require_remote "lib/model/event/remove_equipment_event.rb"
require_remote "lib/model/event/save_event.rb"
require_remote "lib/model/event/shot_event.rb"
require_remote "lib/model/event/show_item_note_event.rb"
require_remote "lib/model/event/show_key_config_window_event.rb"
require_remote "lib/model/event/show_menu_event.rb"
require_remote "lib/model/event/show_message_event.rb"
require_remote "lib/model/event/show_start_menu_event.rb"
require_remote "lib/model/event/talk_event.rb"
require_remote "lib/model/event/underfoot_event.rb"
require_remote "lib/model/event/wait_input_event.rb"
require_remote "lib/model/event/warp_event.rb"
require_remote "lib/model/event/yes_no_event.rb"

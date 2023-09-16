module MeiroSeeker
  # キーコンフィグの設定を行うウィンドウ
  class KeyConfigWindow < BaseMenuWindow
    position WINDOW_POSITION[:key_config]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:key_config],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    BUTTON_RANGE  = 0..5
    UNDO_INDEX    = 6
    DEFAULT_INDEX = 7
    APPLY_INDEX   = 8
    PADDING = 16
    BEHAVIORS = [
                 :ok,
                 :cancel,
                 :option,
                 :menu,
                 :diagonal,
                 :shot,
                ]

    def initialize(scene, x=nil, y=nil, font_type=:regular)
      @tmp_key_config = InputManager.key_config.dup
      choices = {
        MessageManager.get(:ok_attack)      => nil,
        MessageManager.get(:cancel)         => nil,
        MessageManager.get(:direction_sort) => nil,
        MessageManager.get(:menu)           => nil,
        MessageManager.get(:diagonal_move)  => nil,
        MessageManager.get(:shot)           => nil,
        MessageManager.get(:undo)    => lambda { undo },
        MessageManager.get(:default) => lambda { default },
        MessageManager.get(:apply)   => lambda { apply },
      }
      super(choices, x, y, font_type)
    end

    def text
      res = []
      @choices.each_with_index do |choice, idx|
        arrow = (@select == idx) ? '>' : ' '
        if idx < UNDO_INDEX
          origin = choice_to_text(choice)
          padding = PADDING - origin.size
          str = sprintf("%#{padding}s", origin)
        else
          str = choice_to_text(choice)
        end
        res << "#{arrow} #{str}"
      end
      join_choices(res)
    end

    def join_choices(choices)
      buttons = BUTTON_RANGE.map { |idx|
        nkey = @tmp_key_config[BEHAVIORS[idx]]
        symkey = InputManager.get_symkey_by_native_key(nkey)
        "#{choices[idx]} - #{symkey}"
      }.join("\n")

      actions = choices[UNDO_INDEX..APPLY_INDEX].join("\n")

      [buttons, actions].join("\n\n")
    end

    def configurable?
      BUTTON_RANGE.include?(@select)
    end

    def selectable?
      @select >= UNDO_INDEX
    end

    def set(key)
      native_key = InputManager.native_key(key)
      if exist = @tmp_key_config.invert[native_key]
        @tmp_key_config[exist] = nil
      end
      behavior = BEHAVIORS[@select]
      @tmp_key_config[behavior] = native_key
    end

    def undo
      @tmp_key_config = InputManager.key_config.dup
      false
    end

    def default
      @tmp_key_config = InputManager::DEFAULT_KEY_CONFIG.dup
      false
    end

    def apply
      # TODO: 失敗時に注意喚起を行う
      return false if @tmp_key_config.values.include?(nil)
      InputManager.set_key_config(@tmp_key_config)
      true
    end
  end
end

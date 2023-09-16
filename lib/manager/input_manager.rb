module MeiroSeeker
  # キー入力を管理するクラス
  class InputManager
    INPUT = InputProxy.new

    DEFAULT_KEY_CONFIG = {
      up:        INPUT.key(:UP),
      down:      INPUT.key(:DOWN),
      left:      INPUT.key(:LEFT),
      right:     INPUT.key(:RIGHT),
      pad_up:    INPUT.key(:PAD_UP),
      pad_down:  INPUT.key(:PAD_DOWN),
      pad_left:  INPUT.key(:PAD_LEFT),
      pad_right: INPUT.key(:PAD_RIGHT),
      option:    INPUT.key(:A),
      diagonal:  INPUT.key(:Q), # 斜め移動用
      menu:      INPUT.key(:S),
      shot:      INPUT.key(:W),
      cancel:    INPUT.key(:X),
      ok:        INPUT.key(:Z),
      # PAD用
      # ok:        INPUT.key(:PAD_BUTTON0),
      # cancel:    INPUT.key(:PAD_BUTTON1),
      # menu:      INPUT.key(:PAD_BUTTON2),
      # option:    INPUT.key(:PAD_BUTTON3),
      # shot:      INPUT.key(:PAD_BUTTON4),
      # diagonal:  INPUT.key(:PAD_BUTTON5), # 斜め移動用
    }

    USABLE_KEYS = [:A, :C, :D, :E, :Q, :S, :W, :X, :Z]
    USABLE_PBUTTONS = [:PAD_BUTTON0,  :PAD_BUTTON1,  :PAD_BUTTON2,
                       :PAD_BUTTON3,  :PAD_BUTTON4,  :PAD_BUTTON5,
                       :PAD_BUTTON6,  :PAD_BUTTON7,  :PAD_BUTTON8,
                       :PAD_BUTTON9,  :PAD_BUTTON10, :PAD_BUTTON11,
                       :PAD_BUTTON12, :PAD_BUTTON13, :PAD_BUTTON14,
                       :PAD_BUTTON15]

    @key_config = DEFAULT_KEY_CONFIG.dup

    class << self
      def key_config
        self.instance_variable_get(:@key_config)
      end

      def set_key_config(conf)
        self.instance_variable_set(:@key_config, conf)
      end

      def native_key(key)
        INPUT.key(key)
      end

      def get_symkey_by_native_key(nkey)
        INPUT.class::KEY.invert[nkey]
      end

      def get_input_xy
        [get_x, get_y]
      end

      def get_x
        INPUT.get_x
      end

      def get_y
        INPUT.get_y
      end

      def get_push_xy
        [get_push_x, get_push_y]
      end

      def get_push_x
        if INPUT.key_push?(key_config[:left]) ||
           INPUT.key_push?(key_config[:pad_left])
          -1
        elsif INPUT.key_push?(key_config[:right]) ||
              INPUT.key_push?(key_config[:pad_right])
          1
        else
          0
        end
      end

      def get_push_y
        if INPUT.key_push?(key_config[:up]) ||
           INPUT.key_push?(key_config[:pad_up])
          -1
        elsif INPUT.key_push?(key_config[:down]) ||
              INPUT.key_push?(key_config[:pad_down])
          1
        else
          0
        end
      end

      def get_pushed_key
        (USABLE_KEYS + USABLE_PBUTTONS).each do |sym|
          return sym if INPUT.key_push?(INPUT.key(sym))
        end
        nil
      end

      DEFAULT_KEY_CONFIG.keys.each do |key_name|
        define_method("push_#{key_name}?".to_sym) do
          INPUT.key_push?(key_config[key_name])
        end

        define_method("down_#{key_name}?".to_sym) do
          INPUT.key_down?(key_config[key_name])
        end
      end

      def any_key?
        res = false
        get_input_xy.each {|d| res = true if !d.zero? }
        return res if res

        DEFAULT_KEY_CONFIG.each_key do |key|
          res ||= INPUT.key_down?(key_config[key])
          break if res
        end
        res
      end

      def push_sort?
        INPUT.key_down?(key_config[:option])
      end

      def down_dash?
        INPUT.key_down?(key_config[:cancel])
      end

      # OKボタン、キャンセルボタン同時押しで足踏み
      def down_stamp?
        INPUT.key_down?(key_config[:ok]) &&
          INPUT.key_down?(key_config[:cancel])
      end
    end
  end
end

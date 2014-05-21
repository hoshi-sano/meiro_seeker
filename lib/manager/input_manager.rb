module MyDungeonGame
  class InputManager
    INPUT = InputProxy.new

    # TODO: キーコンフィグを使えるようにする
    DEFAULT_KEY_CONFIG = {
      up:       INPUT.key(:UP),
      down:     INPUT.key(:DOWN),
      left:     INPUT.key(:LEFT),
      right:    INPUT.key(:RIGHT),
      option:   INPUT.key(:A),
      diagonal: INPUT.key(:Q), # 斜め移動用
      menu:     INPUT.key(:S),
      cancel:   INPUT.key(:X),
      ok:       INPUT.key(:Z),
    }

    class << self
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
        if INPUT.key_push?(DEFAULT_KEY_CONFIG[:up])
          -1
        elsif INPUT.key_push?(DEFAULT_KEY_CONFIG[:down])
          1
        else
          0
        end
      end

      def get_push_y
        if INPUT.key_push?(DEFAULT_KEY_CONFIG[:left])
          -1
        elsif INPUT.key_push?(DEFAULT_KEY_CONFIG[:right])
          1
        else
          0
        end
      end

      DEFAULT_KEY_CONFIG.keys.each do |key_name|
        define_method("push_#{key_name}?".to_sym) do
          INPUT.key_push?(DEFAULT_KEY_CONFIG[key_name])
        end

        define_method("down_#{key_name}?".to_sym) do
          INPUT.key_down?(DEFAULT_KEY_CONFIG[key_name])
        end
      end

      def any_key?
        res = false
        get_input_xy.each {|d| res = true if !d.zero? }
        return res if res

        DEFAULT_KEY_CONFIG.each_key do |key|
          res ||= INPUT.key_down?(DEFAULT_KEY_CONFIG[key])
          break if res
        end
        res
      end

      def down_dash?
        INPUT.key_down?(DEFAULT_KEY_CONFIG[:cancel])
      end

      # OKボタン、キャンセルボタン同時押しで足踏み
      def down_stamp?
        INPUT.key_down?(DEFAULT_KEY_CONFIG[:ok]) &&
          INPUT.key_down?(DEFAULT_KEY_CONFIG[:cancel])
      end
    end
  end
end

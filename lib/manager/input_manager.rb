module MyDungeonGame
  class InputManager
    INPUT = InputProxy.new

    DEFAULT_KEY_CONFIG = {
      option:   INPUT.key(:A),
      diagonal: INPUT.key(:Q), # 斜め移動用
      menu:     INPUT.key(:S),
      cancel:   INPUT.key(:X),
      ok:       INPUT.key(:Z),
    }

    class << self
      def get_input_xy
        [INPUT.get_x, INPUT.get_y]
      end

      def get_x
        INPUT.get_x
      end

      def get_y
        INPUT.get_y
      end

      # TODO: キーコンフィグを使えるようにする
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

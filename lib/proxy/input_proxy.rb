module MyDungeonGame
  class InputProxy
    KEY = {
      A: :K_A,
      C: :K_C,
      D: :K_D,
      E: :K_E,
      Q: :K_Q,
      S: :K_S,
      W: :K_W,
      X: :K_X,
      Z: :K_Z,
      UP:    :K_UP,
      DOWN:  :K_DOWN,
      LEFT:  :K_LEFT,
      RIGHT: :K_RIGHT,
      PAD_UP:    :P_UP,
      PAD_DOWN:  :P_DOWN,
      PAD_LEFT:  :P_LEFT,
      PAD_RIGHT: :P_RIGHT,
      PAD_BUTTON0: :P_BUTTON0,
      PAD_BUTTON1: :P_BUTTON1,
      PAD_BUTTON2: :P_BUTTON2,
      PAD_BUTTON3: :P_BUTTON3,
      PAD_BUTTON4: :P_BUTTON4,
      PAD_BUTTON5: :P_BUTTON5,
      PAD_BUTTON6: :P_BUTTON6,
      PAD_BUTTON7: :P_BUTTON7,
      PAD_BUTTON8: :P_BUTTON8,
      PAD_BUTTON9: :P_BUTTON9,
      PAD_BUTTON10: :P_BUTTON10,
      PAD_BUTTON11: :P_BUTTON11,
      PAD_BUTTON12: :P_BUTTON12,
      PAD_BUTTON13: :P_BUTTON13,
      PAD_BUTTON14: :P_BUTTON14,
      PAD_BUTTON15: :P_BUTTON15,
    }

    def key(sym)
      KEY[sym]
    end

    def get_x
      Input.x
    end

    def get_y
      Input.y
    end

    def const_get(key)
      Object.const_get(key)
    end

    def key_push?(key)
      if key[0] == 'K'
        Input.key_push?(const_get(key))
      else
        Input.pad_push?(const_get(key))
      end
    end

    def key_down?(key)
      if key[0] == 'K'
        Input.key_down?(const_get(key))
      else
        Input.pad_down?(const_get(key))
      end
    end
  end
end

module MyDungeonGame
  class InputProxy
    KEY = {
      A: K_A,
      Q: K_Q,
      S: K_S,
      W: K_W,
      X: K_X,
      Z: K_Z,
      UP:    K_UP,
      DOWN:  K_DOWN,
      LEFT:  K_LEFT,
      RIGHT: K_RIGHT,
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

    def key_push?(key)
      Input.key_push?(key)
    end

    def key_down?(key)
      Input.key_down?(key)
    end
  end
end

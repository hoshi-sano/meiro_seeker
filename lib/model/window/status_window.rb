module MeiroSeeker
  # ステータスの表示用ウインドウ
  # 武器の強さ、盾の強さ、攻撃力、防御力、満腹度、力、経験値
  class StatusWindow < MessageWindow
    bg_image ViewProxy.rect(*WINDOW_SIZE[:message],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    def initialize(player, font_type=:regular)
      @player = player
      super(create_status_string(@player), nil, font_type)
      # メッセージが流れない(アニメーションしない)ように
      self.newline!
      self.permanence!
    end

    def update
      self.clear
      @message = create_status_string(@player)
      self.newline!
    end

    def create_status_string(player)
      name  = sprintf("%-10s", player.name)
      weapon = [MessageManager.get(:weapon_strength),
                sprintf("%3d", player.weapon_strength)].join(": ")
      shield = [MessageManager.get(:shield_strength),
                sprintf("%5d", player.shield_strength)].join(": ")
      offence = [MessageManager.get(:offence),
                 sprintf("%3d", player.offence)].join(": ")
      defence = [MessageManager.get(:defence),
                 sprintf("%3d", player.defence)].join(": ")
      stomach = [MessageManager.get(:stomach),
                 [sprintf("%3d", player.stomach),
                  sprintf("%3d", player.max_stomach)].join("/")].join(": ")
      power = [MessageManager.get(:power),
               [sprintf("%2d", player.power),
                sprintf("%-2d", player.max_power)].join("/")].join(": ")
      exp = [MessageManager.get(:experience),
             sprintf("%-12d", player.exp)].join(": ")

      "#{name}                          #{stomach}\n" \
      "#{weapon}   #{offence}       #{power}\n" \
      "#{shield}   #{defence}       #{exp}"
    end
  end
end

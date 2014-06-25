module MyDungeonGame
  class SubMenuWindow < BaseMenuWindow
    position WINDOW_POSITION[:sub_menu]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:sub_menu],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true
  end
end

module MyDungeonGame
  class GameStartingWindow < BaseMenuWindow
    position WINDOW_POSITION[:title_menu]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:title_menu],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status false
  end
end

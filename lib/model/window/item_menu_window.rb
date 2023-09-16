module MeiroSeeker
  class ItemMenuWindow < BaseMenuWindow
    position WINDOW_POSITION[:item_menu]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:item_menu],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true
  end
end

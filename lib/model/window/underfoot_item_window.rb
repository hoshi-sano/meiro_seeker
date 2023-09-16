module MeiroSeeker
  class UnderfootItemWindow < ItemWindow
    position WINDOW_POSITION[:item]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:underfoot_item],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])
    show_status true

    def get_event(scene)
      return if @choices.size.zero?
      @choices[@select].underfoot_event(scene)
    end
  end
end

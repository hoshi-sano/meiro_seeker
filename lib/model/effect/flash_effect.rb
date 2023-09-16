module MeiroSeeker
  # フラッシュ光のエフェクト
  # 他のエフェクトと組合せて利用することを想定
  module FlashEffect
    module_function
    def image;  ViewProxy.rect([DISPLAY_WIDTH, DISPLAY_HEIGHT]).image;  end
    def width;  self.image.width; end
    def height; self.image.height; end

    def momentary_flash_event
      Event.new do |e|
        OutputManager.reserve_draw_center(self, :effect)
        e.finalize
      end
    end
  end
end

module MyDungeonGame
  # 広がる光のエフェクト
  module LightEffect
    module_function
    def image;  ViewProxy.rect(DISPLAY_WIDTH, DISPLAY_HEIGHT).image; end
    def width;  self.image.width; end
    def height; self.image.height; end

    # 縦方向の光が画面いっぱいに広がるエフェクト
    def vertical_light_event
      i = 7
      Event.new do |e|
        n = (i > 0) ? i : 1
        scale_x = 1.0 / n
        OutputManager.reserve_draw_center(self, :effect, scale_x: scale_x)
        i -= 1
        e.finalize if i < 0
      end
    end
  end
end

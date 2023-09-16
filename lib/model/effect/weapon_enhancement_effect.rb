module MeiroSeeker
  # 武器強化エフェクト
  class WeaponEnhancementEffect < Effect
    pattern_x       1
    pattern_y       1
    update_interval 1
    image_path      File.join(ROOT, 'data', 'weapon-enhancement-effect.png')

    ANIMATION_SCALES = [[[1.00, 1.00]],
                        [[1.00, 1.00], [0.95, 0.95]],
                        [[1.00, 1.00], [0.95, 0.95], [0.90, 0.90]],
                        [[0.95, 0.95], [0.90, 0.90], [0.85, 0.85]],
                        [[0.90, 0.90], [0.85, 0.85], [0.80, 0.80]],
                        [[0.85, 0.85], [0.80, 0.80], [0.75, 0.75]],
                        [[0.80, 0.80], [0.75, 0.75], [0.70, 0.70]],
                        [[0.75, 0.75], [0.70, 0.70], [0.65, 0.65]],
                        [[0.70, 0.70], [0.65, 0.65]],
                        [[0.65, 0.65]]]
    BRIGHT_ANIMATION_SCALES = [[[0.65, 0.65]],
                               [[0.70, 0.70], [0.75, 0.75], [0.80, 0.80]],
                               [[0.75, 0.75], [0.70, 0.70], [1.00, 1.00]],
                               [[0.70, 0.70], [0.75, 0.75], [1.40, 1.40]],
                               [[0.75, 0.75], [0.70, 0.70], [2.00, 2.00]],
                              ]
    # 元画像の白抜き画像を作成
    WHITE_IMAGE = ViewProxy.rect([284, 284], [0, 0, 0], 0)
    (0...284).each do |x|
      (0...284).each do |y|
        alpha = self.instance_variable_get(:@images)[0][0][x, y][0]
        WHITE_IMAGE.image[x, y] = [alpha, 255, 255, 255] if alpha != 0
      end
    end

    def scale_animation_event
      i = 0.0
      Event.new do |e|
        ANIMATION_SCALES[i.to_i].each do |sx, sy|
          opts = { scale_x: sx, scale_y: sy, alpha: 80 }
          OutputManager.reserve_draw_center(self, :effect, opts)
        end
        i += 0.5 # 2フレームずつ表示するために0.5加算
        e.finalize if i >= ANIMATION_SCALES.size
      end
    end

    def bright_animation_event
      j = 0
      x, y = *ANIMATION_SCALES[-1][0]
      opts_1 = { scale_x: x, scale_y: y, alpha: 200 }
      flash = FlashEffect.momentary_flash_event
      animation = Event.new do |e|
        BRIGHT_ANIMATION_SCALES[j].each do |sx, sy|
          OutputManager.reserve_draw_center(self, :effect, opts_1)
          opts_2 = { scale_x: sx, scale_y: sy, alpha: 200 }
          OutputManager.reserve_draw_center(WHITE_IMAGE, :effect, opts_2)
        end
        j += 1
        e.finalize if j >= BRIGHT_ANIMATION_SCALES.size
      end
      flash.set_next(animation)
      flash
    end

    def event
      first_event = scale_animation_event
      first_event.set_next(bright_animation_event)
      first_event
    end
  end
end

module MyDungeonGame
  class OutputManager
    DISPLAYS = {
      map:       ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      object:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      character: ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      window:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      effect:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      radar_map: ViewProxy.new(RADAR_MAP_UNIT_SIZE * WIDTH_TILE_NUM,
                               RADAR_MAP_UNIT_SIZE * HEIGHT_TILE_NUM),
    }.freeze

    class << self
      def init(player_x, player_y)
        # 画面中心にマスの中心が来るよう初期位置をずらす
        # MEMO: (7, 5)
        @map_offset_x = -(TILE_WIDTH * (player_x - 6)) +
                        ((DISPLAY_WIDTH % TILE_WIDTH) / 2)
        @map_offset_y = -(TILE_HEIGHT * (player_y - 4)) + (TILE_HEIGHT / 2)

        @display_range_begin_x = (TILE_WIDTH * (player_x - 6))
        @display_range_begin_y = (TILE_HEIGHT * (player_y - 4))
      end

      def modify_map_offset(dx, dy)
        @display_range_begin_x += dx
        @display_range_begin_y += dy
        @map_offset_x += dx * -1
        @map_offset_y += dy * -1
      end

      # 引数は実座標
      def display_target?(x, y, obj)
        x + obj.width > (@display_range_begin_x - TILE_WIDTH) &&
          y + obj.height > (@display_range_begin_y - TILE_HEIGHT) &&
          x < (@display_range_begin_x + DISPLAY_WIDTH + TILE_WIDTH) &&
          y < (@display_range_begin_y + DISPLAY_HEIGHT + TILE_HEIGHT)
      end

      def reserve_draw(x, y, obj, type=:object)
        if display_target?(x, y, obj) && DISPLAYS[type]
          x += @map_offset_x
          y += @map_offset_y
          DISPLAYS[type].reserve_draw(x, y, obj.image, DISPLAYS.keys.index(type))
          true
        else
          false
        end
      end

      def reserve_draw_message_window(window)
        # windowの表示
        # TODO: window.imageがダサいのでなんとかする
        args = [window.image, 0, 180, :window]
        reserve_draw_center_with_calibration(*args)
        # テキストの表示
        # TODO: windowの幅を超えそうな場合は改行を入れる
        font = FontProxy.get_font(window.font_type)
        args = [40, 380, window.text, font, DISPLAYS.keys.index(:window)]
        DISPLAYS[:window].reserve_draw_text(*args)
        # TODO: 話者の名前、画像の表示
      end

      def reserve_draw_without_offset(x, y, obj, type=:radar_map)
        if DISPLAYS[type]
          DISPLAYS[type].reserve_draw(x, y, obj.image, DISPLAYS.keys.index(type))
          true
        else
          false
        end
      end

      def reserve_draw_center(obj, type=:character)
        x = (DISPLAY_WIDTH / 2) - (obj.width / 2)
        y = (DISPLAY_HEIGHT / 2) - (obj.height / 2)
        DISPLAYS[type].reserve_draw(x, y, obj.image, DISPLAYS.keys.index(type))
      end

      def reserve_draw_center_with_calibration(obj, cx, cy, type=:character)
        x = (DISPLAY_WIDTH / 2) - (obj.width / 2) + cx
        y = (DISPLAY_HEIGHT / 2) - (obj.height / 2) + cy
        DISPLAYS[type].reserve_draw(x, y, obj.image, DISPLAYS.keys.index(type))
      end

      def update
        DISPLAYS.each do |type, display|
          case type
          when :radar_map
            x = (DISPLAY_WIDTH / 2) - (display.width / 2)
            y = (DISPLAY_HEIGHT / 2) - (display.height / 2)
            display.exec_draw(x, y)
          else
            display.exec_draw(0, 0)
          end
        end
      end
    end
  end
end

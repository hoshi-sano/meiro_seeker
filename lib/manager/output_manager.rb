module MyDungeonGame
  class OutputManager
    DISPLAYS = {
      map:       ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      object:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      character: ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      window:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      effect:    ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      parameter: ViewProxy.new(DISPLAY_WIDTH, DISPLAY_HEIGHT),
      radar_map: ViewProxy.new(RADAR_MAP_UNIT_SIZE * WIDTH_TILE_NUM,
                               RADAR_MAP_UNIT_SIZE * HEIGHT_TILE_NUM),
    }.freeze
    PARAMETER_BACK = ViewProxy.rect(*WINDOW_SIZE[:parameter],
                                    WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

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

      def reserve_draw_parameter(floor_number=1, player)
        # パラメータの背景を表示
        args = [PARAMETER_BACK, 0, -215, :parameter]
        reserve_draw_center_with_calibration(*args)

        # フォーマットを利用してパラメータの文字列を作成
        parm_str = format_parameter(floor_number, player)
        font = FontProxy.get_font(:regular)
        args = [10, 10, parm_str, font, DISPLAYS.keys.index(:parameter)]
        DISPLAYS[:parameter].reserve_draw_text(*args)
        # HPメーターの表示
        create_hp_meter(player).each do |meter|
          args = [290, 30, meter, :parameter]
          reserve_draw_without_offset(*args)
        end
        # 満腹度の表示
        create_stomach_meter(player).each do |meter|
          args = [290, 35, meter, :parameter]
          reserve_draw_without_offset(*args)
        end
      end

      # 表示するパラメータ文字列を生成する
      def format_parameter(floor_number, player)
        sprintf("%3d", floor_number) + "F" + (" " * 18) +
          "Lv" + sprintf("%-2d", player.level) + (" " * 2) +
          "HP" + sprintf("%3d", player.hp) +
          "/" + sprintf("%-3d", player.max_hp) +(" " * 16) +
          sprintf("%6d", player.money) + "G"
      end

      # HPメーターを生成して返す
      def create_hp_meter(player)
        res = []
        @max_hp ||= player.max_hp
        @hp ||= player.hp
        # HPの変化がない場合は既存のものを返す
        res[0] = @max_hp_meter if @max_hp == player.max_hp
        res[1] = @hp_meter if @hp == player.hp

        [[:max_hp, :max],
         [:hp, :current]].each_with_index do |method_key, i|
          next if res[i]
          method, key = *method_key
          args = [player.send(method), HP_METER_HEIGHT,
                  HP_METER_COLOR[key], HP_METER_ALPHA[key]]
          res[i] = ViewProxy.rect(*args)
        end
        res
      end

      # 満腹度メーターを生成して返す
      def create_stomach_meter(player)
        res = []
        @max_stomach ||= player.max_stomach
        @stomach ||= player.stomach
        # 満腹度の変化がない場合は既存のものを返す
        res[0] = @max_stomach_meter if @max_stomach == player.max_stomach
        res[1] = @stomach_meter if @stomach == player.stomach
        [[:max_stomach, :max],
         [:stomach, :current]].each_with_index do |method_key, i|
          next if res[i]
          method, key = *method_key
          args = [player.send(method), STOMACH_METER_HEIGHT,
                  STOMACH_METER_COLOR[key], STOMACH_METER_ALPHA[key]]
          res[i] = ViewProxy.rect(*args)
        end
        res
      end

      # メッセージ用ウインドウの表示
      def reserve_draw_message_window(window)
        # TODO: 数値の定数化
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

      # ２択ウインドウの表示
      def reserve_draw_yes_no_window(window)
        # TODO: 数値の定数化
        # windowの表示
        args = [window.image, 200, -60, :window]
        reserve_draw_center_with_calibration(*args)
        # テキストの表示
        font = FontProxy.get_font(window.font_type)
        args = [460, 150, window.text, font, DISPLAYS.keys.index(:window)]
        DISPLAYS[:window].reserve_draw_text(*args)
      end

      def reserve_draw_menu_window(window)
        # windowの表示
        args = [window.x, window.y, window.image, :window]
        reserve_draw_without_offset(*args)
        # テキストの表示
        left_text, right_text = window.text
        font = FontProxy.get_font(window.font_type)
        args = [*window.left_text_position, left_text, font,
                DISPLAYS.keys.index(:window)]
        DISPLAYS[:window].reserve_draw_text(*args)
        args = [*window.right_text_position, right_text, font,
                DISPLAYS.keys.index(:window)]
        DISPLAYS[:window].reserve_draw_text(*args)
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

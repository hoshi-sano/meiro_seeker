module MyDungeonGame
  # キャラクターの通常移動イベント
  # 数フレームかけて対象のマスへ移動するためにイベントを細分化して発行する。
  module MoveEvent
    module_function

    # 引数のdx, dyはマスの幅と高さを掛けた実座標
    def create(scene, dx, dy, dash=false)
      scene.instance_eval do
        if dash
          event = MoveEvent.create_unit_move_event(self, dx, dy)
        else
          x_move_unit = dx >= 0 ? MOVE_UNIT : MOVE_UNIT * -1
          y_move_unit = dy >= 0 ? MOVE_UNIT : MOVE_UNIT * -1
          dx_ary = Array.new((dx / x_move_unit), x_move_unit)
          dy_ary = Array.new((dy / y_move_unit), y_move_unit)
          length = [dx_ary.size, dy_ary.size].max
          [dx_ary, dy_ary].each do |ary|
            if (lack = length - ary.size) > 0
              ary.concat(Array.new(lack, 0))
            end
          end

          x, y = dx_ary.shift, dy_ary.shift
          event = MoveEvent.create_unit_move_event(self, x, y)

          dx_ary.zip(dy_ary).each do |x, y|
            event.set_next(MoveEvent.create_unit_move_event(self, x, y))
          end
        end
        event
      end
    end

    def create_unit_move_event(scene, x, y)
      scene.instance_eval do
        Event.new do |e|
          OutputManager.modify_map_offset(x, y)
          @player.update
          update_mobs
          move_mobs
          e.finalize
        end
      end
    end
  end
end

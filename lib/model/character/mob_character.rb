module MyDungeonGame
  # プレイヤー以外のキャラクターのベースとなるクラス
  class MobCharacter < Character
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    name "MOB"

    attr_accessor :messages, :active_gauge

    def initialize(floor)
      super(floor)
      @next_xy = []
      @active_gauge = 0
      @messages = []
    end

    def disp_x
      @disp_x || self.x * TILE_WIDTH
    end

    def disp_y
      @disp_y || self.y * TILE_HEIGHT
    end

    def push_next_xy(xy)
      @next_xy.push(xy)
    end

    def checked_events(checker)
      # TODO: 柔軟なイベント発生ができるようにする
      @messages.map do |msg|
        EventPacket.new(TalkEvent, self, msg, checker)
      end
    end

    # actionが可能か否か
    def ready?
      alive? && (@active_gauge >= 1)
    end

    def pre_action
      @active_gauge += @speed
    end

    def post_action
      @active_gauge = 0 if @active_gauge >= 1
      @warped = false
      # ステータス異常の回復
      recover_temporary_status
    end

    def action
      pre_action
      return if not ready?
      @active_gauge.to_i.times { _action }
      post_action
    end

    def _action
      random_walk
    end

    # ランダム歩行
    # ランダムに決めた移動先が進行不可の場合は向きだけ変更する
    def random_walk
      dx, dy = random_walk_dxdy
      change_direction_by_dxdy(dx, dy)

      walk_to(dx, dy)
    end

    def walk_to(dx, dy)
      if movable?(dx, dy)
        if @next_xy.any?
          basic_x, basic_y = *@next_xy[-1]
        else
          basic_x, basic_y = self.x, self.y
        end

        @floor.move_character(basic_x, basic_y, basic_x + dx, basic_y + dy)
        push_next_xy([basic_x + dx, basic_y + dy])
      end
    end

    def update
      @disp_x = nil
      @disp_y = nil
      super
    end

    # 見た目上の移動を実現するためのメソッド
    def move
      if moving_plan
        next_xy = moving_plan.shift
        if next_xy
          prev_disp_x, prev_disp_y = disp_x, disp_y
          @disp_x = next_xy[0]
          @disp_y = next_xy[1]
          # 移動中は移動方向に向きを変える
          dx = prev_disp_x - @disp_x
          dy = prev_disp_y - @disp_y
          change_direction_by_dxdy(dx, dy)
        else
          @moving_plan = nil
        end
      end
    end

    def moving?
      # !!(@disp_x && @disp_y)
      !!moving_plan
    end

    def moving_plan
      @moving_plan ||= create_moving_plan
    end

    def create_moving_plan
      return nil if !@next_xy || @next_xy.empty?
      # 1updateにつき移動する座標の長さを決める
      step = @next_xy.size
      move_unit = MOVE_UNIT * step

      # 通常、6フレームかけて移動する
      # (マスの大きさ/MOVE_UNIT) = 48/8 = 6
      plan_length = TILE_WIDTH / MOVE_UNIT
      # 通常速度: 6, 倍速: 3, 3倍速: 2
      plan_unit_length = plan_length / step

      start_x, start_y = *@prev_xy[-@next_xy.size]
      res = [[start_x * TILE_WIDTH, start_y * TILE_HEIGHT]]
      # 現在の座標(prev_x, prev_y)から目的の座標(@next_xy)までを
      # 細分化した移動計画を返す
      # 1ターンに複数回移動する場合は「次の現在の座標」を@next_xyから取得
      @next_xy.each_with_index do |xy, i|
        x, y = *xy
        start_x, start_y = *@next_xy[i - 1] if i != 0
        dx = (x - start_x) * TILE_WIDTH
        dy = (y - start_y) * TILE_HEIGHT
        ddx = dx / plan_unit_length
        ddy = dy / plan_unit_length
        plan_unit_length.times do
          ddx = dx if dx.abs < ddx.abs
          ddy = dy if dy.abs < ddy.abs
          last = res[-1]
          res << [last[0] + ddx, last[1] + ddy]
          dx -= ddx
          dy -= ddy
        end
      end

      @next_xy.clear
      @prev_xy = @prev_xy[(0 - @speed.ceil)..-1] || @prev_xy
      res
    end

    # 移動計画やその材料をクリアすることで、
    # 数フレーム使った移動を禁止する
    def do_not_animation_move
      @next_xy = []
      @moving_plan = nil
    end

    def keep_prev
      @next_xy = []
      @moving_plan = nil
      @disp_x = prev_x * TILE_WIDTH
      @disp_y = prev_y * TILE_HEIGHT
    end

    private

    def image_path
      self.class.instance_variable_get(:@image_path)
    end
  end
end

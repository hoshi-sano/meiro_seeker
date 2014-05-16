module MyDungeonGame
  # プレイヤー以外のキャラクターのベースとなるクラス
  class MobCharacter < Character
    class << self
      def image_path(val)
        @image_path = val
      end
    end

    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH

    def initialize(floor)
      super(image_path, floor)
      @next_xy = []
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

    def action
      return if @hp <= 0
      random_walk
    end

    # ランダム歩行
    # ランダムに決めた移動先が進行不可の場合は向きだけ変更する
    def random_walk
      dx = DungeonManager.randomizer.rand(3) - 1
      dy = DungeonManager.randomizer.rand(3) - 1
      change_direction_by_dxdy(dx, dy)

      walk_to(dx, dy)
    end

    def walk_to(dx, dy)
      if movable?(dx, dy)
        @floor.move_character(self.x, self.y, self.x + dx, self.y + dy)
        push_next_xy([self.x + dx, self.y + dy])
      end
    end

    def throughable?(dx, dy)
      @floor.throughable?(self.x, self.y, self.x + dx, self.y + dy)
    end

    def movable?(dx, dy)
      @floor.movable?(self.x, self.y, self.x + dx, self.y + dy)
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
          @disp_x = next_xy[0]
          @disp_y = next_xy[1]
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

      res = [[@prev_x * TILE_WIDTH, @prev_y * TILE_HEIGHT]]
      # 現在の座標(@prev_x, prev_y)から目的の座標(@next_xy)までを
      # 細分化した移動計画を返す
      @next_xy.each_with_index do |xy, i|
        x, y = *xy
        dx = (x - self.x) * TILE_WIDTH
        dy = (y - self.y) * TILE_HEIGHT
        ddx = dx / plan_unit_length
        ddy = dy / plan_unit_length
        plan_unit_length.times do |j|
          ddx = dx if dx.abs < ddx.abs
          ddy = dy if dy.abs < ddy.abs
          last = res[-1]
          res << [last[0] + ddx, last[1] + ddy]
          dx -= ddx
          dy -= ddy
        end
      end

      @next_xy.clear
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
      @disp_x = @prev_x * TILE_WIDTH
      @disp_y = @prev_y * TILE_HEIGHT
    end

    private

    def image_path
      self.class.instance_variable_get(:@image_path)
    end
  end
end

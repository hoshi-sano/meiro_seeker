module MyDungeonGame
  class Character
    class << self
      def type(value)
        @type = value
      end

      def get_type
        @type || :mob
      end

      def update_interval(value)
        @update_interval = value
      end

      def get_update_interval
        @update_interval || 10
      end

      def hp(value)
        @default_hp = value
      end

      def default_hp
        @default_hp || 1
      end

      def hate(value)
        @hate = !!value
      end

      def hate?
        @hate
      end

      # 表示用のダミーを返す
      # ダミーはクラスで使いまわす
      def display_dummy(instance)
        return @dummy if @dummy
        @dummy = instance.dup
        @dummy.show
        @dummy
      end
    end

    # 通路などを直進する際の、自身の向いている方向と
    # 移動先候補のマッピング
    DIRECTION_STEP_MAP = {
      CHARACTER_DIRECTION[:S] => {
        forward:  [0,  1],
        left:     [1,  0],
        right:    [-1, 0],
        backward: [0, -1],
      },
      CHARACTER_DIRECTION[:W] => {
        forward:  [-1, 0],
        left:     [0,  1],
        right:    [0, -1],
        backward: [1,  0],
      },
      CHARACTER_DIRECTION[:E] => {
        forward:  [1,  0],
        left:     [0, -1],
        right:    [0,  1],
        backward: [-1, 0],
      },
      CHARACTER_DIRECTION[:N] => {
        forward:  [0, -1],
        left:     [-1, 0],
        right:    [1,  0],
        backward: [0,  1],
      },
      CHARACTER_DIRECTION[:SW] => {
        forward:  [-1,  1],
        left:     [1,   1],
        right:    [-1, -1],
        backward: [1,  -1],
      },
      CHARACTER_DIRECTION[:SE] => {
        forward:  [1,   1],
        left:     [1,  -1],
        right:    [-1,  1],
        backward: [-1, -1],
      },
      CHARACTER_DIRECTION[:NW] => {
        forward:  [-1, -1],
        left:     [-1,  1],
        right:    [1,  -1],
        backward: [1,   1],
      },
      CHARACTER_DIRECTION[:NE] => {
        forward:  [1,  -1],
        left:     [-1, -1],
        right:    [1,   1],
        backward: [-1,  1],
      },
    }

    TRANSPARENCY = ViewProxy.rect(TILE_WIDTH, TILE_HEIGHT,
                                  TRANSPARENT[:color], TRANSPARENT[:alpha])

    attr_accessor :x, :y, :prev_x, :prev_y

    # TODO: 各インスタンスごとに画像をロードしてるのは無駄
    def initialize(img_path, floor)
      self.extend(HelperMethods)
      @images = FileLoadProxy.load_image_tiles(img_path,
                                               CHARACTER_PATTERN_NUM_X,
                                               CHARACTER_PATTERN_NUM_Y)
      @floor = floor
      @current_direction = CHARACTER_DIRECTION[:S]
      @current_frame = 0
      @hide = false
      @events = []

      # ステータス
      @hp = self.class.default_hp
    end

    def type
      self.class.get_type
    end

    def update_interval
      self.class.get_update_interval
    end

    def hate?
      self.class.hate?
    end

    def dead?
      @hp <= 0
    end

    def hide
      @hide = true
    end

    def show
      @hide = false
    end

    def show_switch
      @hide = !@hide
    end

    # 表示用のダミーを返す
    def display_dummy
      dummy = self.class.display_dummy(self)
      dummy.instance_variable_set(:@current_direction, @current_direction)
      dummy
    end

    def has_event?
      @events.any?
    end

    def shift_event
      @events.shift
    end

    def image
      if @hide
        TRANSPARENCY.image
      else
        # MEMO: 斜めの暫定処理
        if @current_direction >= CHARACTER_DIRECTION[:NW]
          direction = CHARACTER_DIRECTION[:N]
        elsif @current_direction >= CHARACTER_DIRECTION[:SW]
          direction = CHARACTER_DIRECTION[:S]
        else
          direction = @current_direction
        end
        # @images[@current_direction][@current_frame]
          @images[direction][@current_frame]
      end
    end

    def normalize(val)
      if val > 0
        1
      elsif val < 0
        -1
      else
        0
      end
    end

    def get_forward_step
      DIRECTION_STEP_MAP[@current_direction][:forward]
    end

    def change_direction_by_dxdy(dx, dy)
      if dx.zero? && dy.zero?
        return
      end
      dx = normalize(dx)
      dy = normalize(dy)
      direction = CHARACTER_INPUT_DIRECTION_MAP[[dx, dy]]
      change_direction(direction)
    end

    def change_direction(direction)
      if CHARACTER_DIRECTION.keys.include?(direction)
        @current_direction = CHARACTER_DIRECTION[direction]
      end
    end

    # 見た目上の更新を行う
    def update
      if update?
        @current_frame += 1
        unless CHARACTER_WALK_PATTERN.include?(@current_frame)
          @current_frame = 0
        end
      end
    end

    def update?
      @next_update ||= update_interval
      @next_update -= 1
      if @next_update <= 0
        @next_update = update_interval
        true
      else
        false
      end
    end

    # 何らかの動作中かどうかを返す
    def updating?
      dead? || moving?
    end

    # 移動処理の途中かどうかを返す
    def moving?
      false
    end

    def width
      @images.first.first.width
    end

    def height
      @images.first.first.height
    end

    def attack_to(target)
      # TODO: 命中判定
      target.attacked_by(self)
      @events << EventPacket.new(AttackEvent, self)
      @events << EventPacket.new(DamageEvent, target)
      if target.dead?
        self.kill(target)
      end
    end

    def attacked_by(attacker)
      # TODO: ダメージ計算など
      @hp -= 5
    end

    def kill(target)
      target.killed
      @events << EventPacket.new(DeadEvent, target)
    end

    def killed
      # TODO: やられ画像に変更し、全ての活動を停止する
    end
  end
end

require 'player_character'
require 'mob_character'
require 'intelligent_character'
require 'follow_player_character'
require 'enemy_character'

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

      def name(value)
        @name = value
      end

      def get_name
        @name
      end

      [
       :hp,
       :level,
       :power,
       :exp,
      ].each do |param_name|
        define_method(param_name) do |value|
          self.instance_variable_set("@default_#{param_name}", value)
        end

        define_method("default_#{param_name}") do
          self.instance_variable_get("@default_#{param_name}") || 1
        end
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

    attr_reader :level, :exp
    attr_accessor :x, :y, :prev_x, :prev_y, :events, :name, :hp, :max_hp,
                  :power

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
      @max_hp = self.class.default_hp
      @hp = self.class.default_hp
      @level = self.class.default_level
      @power = self.class.default_power
      @exp =   self.class.default_exp
    end

    def type
      self.class.get_type
    end

    def update_interval
      self.class.get_update_interval
    end

    def name
      self.class.get_name
    end

    def accuracy
      # TODO: 状態によって数値を変更
      MOB_ATTACK_ACCURACY
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
        @images[@current_direction][@current_frame]
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

    def attack_frame(df)
      frame = CHARACTER_ATTACK_PATTERN.to_a[df]
      return if frame.nil?
      @current_frame = frame
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

    # (self.x + dx, self.y + dy)座標にキャラクターが不在の場合に、
    # (self.x + dx, self.y + dy)座標へ通過可能かどうかを返す
    def throughable?(dx, dy)
      @floor.throughable?(self.x, self.y, self.x + dx, self.y + dy)
    end

    # (self.x + dx, self.y + dy)座標へ移動可能かどうかを返す
    # 既にその座標にキャラクターが居る場合はfalseを返す
    # MEMO: 内部で#throughable?が呼ばれているため、#movable?と
    #       #throughable?は同時に呼ばなくてよい
    def movable?(dx, dy)
      @floor.movable?(self.x, self.y, self.x + dx, self.y + dy)
    end

    def width
      @images.first.first.width
    end

    def height
      @images.first.first.height
    end

    def attack_to(target)
      @events << EventPacket.new(AttackEvent, self)
      if randomizer.rand(100)  < self.accuracy
        damage = target.attacked_by(self)
        @events << EventPacket.new(DamageEvent, target, damage)
        if target.dead?
          self.kill(target)
        end
      else
        msg = MessageManager.missed(self.name)
        @events << EventPacket.new(ShowMessageEvent, msg)
      end
    end

    def attacked_by(attacker)
      damage = calc_damage(attacker, self)
      @hp -= damage
      msg = MessageManager.attack(attacker.name, self.name, damage)
      attacker.events << EventPacket.new(ShowMessageEvent, msg)
      damage
    end

    def kill(target)
      target.killed_by(self)
      @events << EventPacket.new(DeadEvent, target)
    end

    def killed_by(attacker)
      # TODO: やられ画像に変更し、全ての活動を停止する
    end

    # ダメージ計算
    def calc_damage(attacker, target)
      r = (randomizer.rand(250) + 875) / 1000.0 # 0.875 - 1.125
      (attacker.offence * r - defence).round
    end

    # 攻撃力の計算
    def offence
      calc_weapon_calibration +
        calc_level_calibration +
        calc_power_calibration
    end

    # 防御力の計算
    def defence
      # TODO
      0
    end

    # 各種計算式は http://asuka.lsx3.net/ を参照

    # 武器補正の計算
    def calc_weapon_calibration
      0
    end

    # レベル補正の計算
    def calc_level_calibration
      (Math.log((@level / 2) + 1) / Math.log(1.6)) ** 2
    end

    # 力補正の計算
    def calc_power_calibration
      if @power < 8
        ((Math.log(3.0) / Math.log(1.6)) ** 2) * (@power / 8.0)
      else
        ((Math.log((@power / 2.0) - 1) / Math.log(1.6)) ** 2)
      end
    end
  end
end

require 'character/player_character'
require 'character/mob_character'
require 'character/intelligent_character'
require 'character/follow_player_character'
require 'character/enemy_character'

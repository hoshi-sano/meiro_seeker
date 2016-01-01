module MyDungeonGame
  class Character
    class << self
      def type(value)
        @type = value
      end

      def get_type
        @type || :mob
      end

      def image_path(value)
        @image_path = value
        args = [@image_path, CHARACTER_PATTERN_NUM_X, CHARACTER_PATTERN_NUM_Y]
        @images = FileLoadProxy.load_image_tiles(*args)
      end

      def images
        @images
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

      def group(*values)
        raise MustNotHappen, self unless (ENEMY_GROUPS & values) == values
        @groups = values
      end

      def groups
        @groups || [:normal]
      end

      def included?(group_sym)
        groups.include?(group_sym)
      end

      [
       :hp,
       :level,
       :power,
       :defence,
       :exp,
       :speed,
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

      def skill(skill_klass, params)
        @skills ||= {}
        if params.is_a?(Integer)
          invocation_rate = params
          @skills[skill_klass] = {
            rate: invocation_rate,
          }
        else
          skill_params = params.select do |k, _|
            %i(rate item).include?(k)
          end
          @skills[skill_klass] = skill_params
        end
      end

      def get_skills
        @skills ||= {}
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
    attr_accessor :x, :y, :prev_xy, :events, :name, :hp, :max_hp,
                  :power, :defence, :death_animating

    def initialize(floor)
      self.extend(HelperMethods)
      @floor = floor
      @current_direction = CHARACTER_DIRECTION[:S]
      @current_frame = 0
      @hide = false
      @events = []
      @prev_xy = []

      # ステータス
      @max_hp  = self.class.default_hp
      @hp      = self.class.default_hp
      @level   = self.class.default_level
      @power   = self.class.default_power
      @defence = self.class.default_defence
      @exp     = self.class.default_exp
      @speed   = self.class.default_speed
    end

    def type
      self.class.get_type
    end

    def update_interval
      self.class.get_update_interval / @speed
    end

    def name
      self.class.get_name
    end

    def skill_to_rates
      self.class.get_skills.map { |skill_klass, params|
        [skill_klass, params[:rate]]
      }.to_h
    end

    # ItemThrowSkillによって投擲されるアイテムを返す
    def throw_item
      item = (self.class.get_skills[ItemThrowSkill] || {})[:item]
      item.ancestors.include?(Bullet) ? item.new(1) : item.new
    end

    def accuracy
      # TODO: 状態によって数値を変更
      MOB_ATTACK_ACCURACY
    end

    def hate?
      self.class.hate?
    end

    def alive?
      @hp > 0
    end

    def dead?
      @hp <= 0
    end

    def completely_removed?
      dead? && !death_animating?
    end

    def included?(group_sym)
      self.class.included?(group_sym)
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

    def pop_event
      @events.pop
    end

    def image
      if @hide
        TRANSPARENCY.image
      else
        self.class.images[@current_direction][@current_frame]
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

    # objの方向に向きを変える
    def change_direction_to_object(obj)
      if obj
        dx = obj.x - x
        dy = obj.y - y
      else
        dx, dy = 0, 0
      end
      change_direction_by_dxdy(dx, dy)
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

    def death_animating?
      !!@death_animating
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
      self.class.images.first.first.width
    end

    def height
      self.class.images.first.first.height
    end

    def attack_to(target)
      @events << EventPacket.new(AttackEvent, self, target)
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
      @death_animating = true
      # TODO: やられ画像に変更し、全ての活動を停止する
    end

    # ダメージ計算
    def calc_damage(attacker, target)
      r = (randomizer.rand(250) + 875) / 1000.0 # 0.875 - 1.125
      damage = (attacker.offence * r - target.defence).round
      if damage > 0
        damage
      else
        MINIMUM_DAMAGES[randomizer.rand(MINIMUM_DAMAGES.size)]
      end
    end

    # 攻撃力の計算
    def offence
      calc_weapon_calibration +
        calc_level_calibration +
        calc_power_calibration
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

    def prev_x(idx=-1)
      (@prev_xy[idx] || [])[0]
    end

    def prev_y(idx=-1)
      (@prev_xy[idx] || [])[1]
    end

    def prev_x=(prev_x)
      if @prev_xy.any? && @prev_xy[-1][0].nil?
        @prev_xy[-1][0] = prev_x
      else
        @prev_xy << [prev_x, nil]
      end
    end

    def prev_y=(prev_y)
      if @prev_xy.any? && @prev_xy[-1][1].nil?
        @prev_xy[-1][1] = prev_y
      else
        @prev_xy << [nil, prev_y]
      end
    end
  end
end

require 'character/skill'
require 'character/player_character'
require 'character/mob_character'
require 'character/intelligent_character'
require 'character/follow_player_character'
require 'character/enemy_character'

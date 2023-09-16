module MeiroSeeker
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

      def status(*values)
        raise MustNotHappen, self unless (STATUSES & values) == values
        @status = values
      end

      def default_status
        @status || []
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
            %i(rate item after_state message).include?(k)
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
        f_left:   [1,  1],
        f_right:  [-1, 1],
      },
      CHARACTER_DIRECTION[:W] => {
        forward:  [-1, 0],
        left:     [0,  1],
        right:    [0, -1],
        backward: [1,  0],
        f_left:   [-1, 1],
        f_right:  [-1, -1],
      },
      CHARACTER_DIRECTION[:E] => {
        forward:  [1,  0],
        left:     [0, -1],
        right:    [0,  1],
        backward: [-1, 0],
        f_left:   [1, -1],
        f_right:  [1,  1],
      },
      CHARACTER_DIRECTION[:N] => {
        forward:  [0, -1],
        left:     [-1, 0],
        right:    [1,  0],
        backward: [0,  1],
        f_left:   [-1, -1],
        f_right:  [1, -1],
      },
      CHARACTER_DIRECTION[:SW] => {
        forward:  [-1,  1],
        left:     [1,   1],
        right:    [-1, -1],
        backward: [1,  -1],
        f_left:   [0,   1],
        f_right:  [-1,  0],
      },
      CHARACTER_DIRECTION[:SE] => {
        forward:  [1,   1],
        left:     [1,  -1],
        right:    [-1,  1],
        backward: [-1, -1],
        f_left:   [1,   0],
        f_right:  [0,   1],
      },
      CHARACTER_DIRECTION[:NW] => {
        forward:  [-1, -1],
        left:     [-1,  1],
        right:    [1,  -1],
        backward: [1,   1],
        f_left:   [-1,  0],
        f_right:  [0,  -1],
      },
      CHARACTER_DIRECTION[:NE] => {
        forward:  [1,  -1],
        left:     [-1, -1],
        right:    [1,   1],
        backward: [-1,  1],
        f_left:   [0,  -1],
        f_right:  [1,   0],
      },
    }

    TRANSPARENCY = ViewProxy.rect(TILE_WIDTH, TILE_HEIGHT,
                                  TRANSPARENT[:color], TRANSPARENT[:alpha])

    attr_reader :level, :exp, :current_frame, :temporary_status,
                :status_image
    attr_accessor :x, :y, :prev_xy, :events, :name, :hp, :max_hp,
                  :power, :defence, :death_animating, :warped

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

      # 状態管理用
      @warped = nil # ワープ管理用、連続ワープを防ぐために使う
      @temporary_status = {}
      @floor_permanent_status = self.class.default_status

      @status_image = StatusImage.new(self)
    end

    def inspect
      {
        name:              name,
        type:              type,
        hp:                "#{@hp}/#{@max_hp}",
        xy:                [@x, @y],
        hide:              @hide,
        current_direction: @current_direction,
        death_animating:   @death_animating,
        temp_status:       @temporary_status,
        floor_status:      @floor_permanent_status,
      }
    end

    def type
      self.class.get_type
    end

    def update_interval
      self.class.get_update_interval / (@speed * (has_status?(:speed_up) ? 2 : 1))
    end

    def name
      self.class.get_name
    end

    def skill_to_rates
      self.class.get_skills.map { |skill_klass, params|
        [skill_klass, params[:rate]]
      }.to_h
    end

    def accuracy
      # TODO: 状態によって数値を変更
      MOB_ATTACK_ACCURACY
    end

    def groups
      self.class.groups
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

    # ワープ可能か否か
    # 既にワープ済だった場合はワープさせない
    def warpable?
      !@wapred
    end

    def completely_removed?
      dead? && !death_animating?
    end

    def included?(group_sym)
      self.class.included?(group_sym)
    end

    def current_speed
      @speed * (has_status?(:speed_up) ? 2 : 1)
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

    def get_forward_step_to_target(target)
      [normalize(target.x - self.x), normalize(target.y - self.y)]
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

    def update
      if update?
        @current_frame += 1
        unless CHARACTER_WALK_PATTERN.include?(@current_frame)
          @current_frame = 0
        end
        @status_image.update
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
      moving?
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
        self.kill(target) if target.dead?
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
      @floor.remove_character(target.x, target.y)
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
      if attacker.type == :player
        # プレイヤーの持っている武器が対象の種族に強い
        # 能力を持っている数の分だけ、1.5を重ねがける
        (target.groups & attacker.defeat).size.times { damage = damage * 1.5 }
      end
      if damage > 0
        damage.round
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

    # 引数に指定したステータス異常の状態であるか否か
    def has_status?(sym)
      @temporary_status.keys.include?(sym) ||
        @floor_permanent_status.include?(sym)
    end

    # 引数に指定したステータス異常に対して体制を持っているか否か
    def anti?(sym)
      anti_sym = "anti_#{sym}".to_sym unless sym.match(/^anti_/)
      @temporary_status.keys.include?(anti_sym) ||
        @floor_permanent_status.include?(anti_sym)
    end

    # 一時的なステータス異常をセット
    def temporary_status_set(sym, turn=10)
      raise MustNotHappen unless STATUSES.include?(sym)
      @temporary_status[sym] = turn
    end

    # 毎ターンのステータス異常の回復
    def recover_temporary_status(step=1)
      res = []
      @temporary_status.keys.each do |key|
        @temporary_status[key] -= step
        if @temporary_status[key] <= 0
          @temporary_status.delete(key)
          res << key
        end
      end
      res
    end

    # 1フロアのみ継続するステータス異常をセット
    def floor_permanent_status_set(sym)
      raise MustNotHappen unless STATUSES.include?(sym)
      @floor_permanent_status << sym unless @floor_permanent_status.include?(sym)
    end

    # 1フロアのみ継続するステータス異常の回復
    def recover_floor_permanent_status(syms=nil)
      if syms.nil?
        @floor_permanent_status = []
      else
        @floor_permanent_status = @floor_permanent_status - Array(syms)
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

    # ランダム歩行用座標を返す
    def random_walk_dxdy(force=false)
      dx = randomizer.rand(3) - 1
      dy = randomizer.rand(3) - 1
      dx, dy = random_walk_dxdy if force && dx.zero? && dy.zero?
      [dx, dy]
    end

    # ステータス状態表示用のクラス
    class StatusImage
      STATUS_IMAGES =
        %i(confusion speed_up).map { |stat|
          file_path = File.join(ROOT, 'data', "#{stat}.png")
          args = [file_path, CHARACTER_STATUS_PATTERN_NUM, 1]
          [stat, FileLoadProxy.load_image_tiles(*args)[0]]
        }.to_h

      class << self
        def displayable_statuses
          STATUS_IMAGES.keys
        end
      end

      def initialize(owner)
        @owner = owner
        @current_frame = 0
        @current_status = 0
      end

      def width
        STATUS_IMAGE_WIDTH
      end

      def height
        STATUS_IMAGE_HEIGHT
      end

      def displayable_statuses
        self.class.displayable_statuses & @owner.temporary_status.keys
      end

      def update
        @current_frame =
          @owner.current_frame % CHARACTER_STATUS_PATTERN_NUM
        if @owner.current_frame.zero? && displayable_statuses.size > 0
          @current_status += 1
          @current_status = @current_status % displayable_statuses.size
        end
      end

      def image
        stats = displayable_statuses
        current_stat_sym = stats[@current_status]
        return TRANSPARENCY.image if current_stat_sym.nil?
        STATUS_IMAGES[current_stat_sym][@current_frame]
      end
    end
  end
end

require 'character/skill'
require 'character/player_character'
require 'character/mob_character'
require 'character/not_walk_character'
require 'character/immovable_character'
require 'character/intelligent_character'
require 'character/follow_player_character'
require 'character/enemy_character'

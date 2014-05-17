module MyDungeonGame
  # 探索モードのシーン
  class ExplorationScene
    RADAR_MAP_IMAGES = {
      player: ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:player], RADAR_MAP_ALPHA[:player]),
      mob:    ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:mob], RADAR_MAP_ALPHA[:mob]),
      tile:   ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:tile], RADAR_MAP_ALPHA[:tile]),
    }.freeze

    def initialize
      extend(HelperMethods)
      @floor = DungeonManager.create_floor

      # 消費ターン数
      @turn = 0

      # アクションフラグ
      # プレイヤーが1ターン消費する行動をとるたびにtrueになる。
      # このフラグがtrueの場合、NPCが行動をとる。
      @do_action = false

      # update待機フラグ
      # 全ての見た目上のupateが完了するまで、キー入力を受け付けないなど
      # の制御を行うために利用する。
      @waiting_update_complete = false

      # NPCの種類、数、初期位置を決定
      @mobs = create_mobs

      # プレーヤーの初期位置を決定
      @player = PlayerCharacter.new(@floor)
      set_random_position(@player)

      OutputManager.init(@player.x, @player.y)
      @em = EventManager.new(WaitInputEvent.create(self))
    end

    def create_mobs
      # TODO: 適切なNPC選択を行う
      res = []
      room_num = @floor.all_rooms.size
      mob_num = DungeonManager.randomizer.rand(room_num) * 2
      mob_num = [room_num + 1, mob_num].max
      mob_num.times do
        mob = EnemyCharacter.new(@floor)
        set_random_position(mob)
        res << mob
      end
      res
    end

    def set_random_position(character)
      x, y = @floor.get_no_one_xy(DungeonManager.randomizer)
      character.x = x
      character.y = y
      character.prev_x = x
      character.prev_y = y
      while player_xy = @floor.get_room(x, y).player_xy
        # 見える範囲には出現させない
        break if !display_target?(character)
        x, y = @floor.get_no_one_xy(DungeonManager.randomizer)
        character.x = x
        character.y = y
        character.prev_x = x
        character.prev_y = y
      end
      @floor[character.x, character.y].character = character
      true
    end

    # 基本のループ処理
    def update
      # 条件・状態によって変化するイベントを処理
      @em.do_event

      # 毎フレームの必須イベントを処理
      display_base_map
      display_palyer
      display_mobs
      display_radar_map
      display_window
      OutputManager.update
    end

    # ターンを消費する
    def tick
      @turn += 1
      # TODO: 1ターンごとのHP回復や状態異常からの復帰など
      @do_action = true
      # TODO: 敵の増加
      if (@turn % RESPAWN_INTERVAL).zero?
        mob = EnemyCharacter.new(@floor)
        set_random_position(mob)
        @mobs << mob
      end
    end

    def activate_mobs
      return if !@do_action
      @mobs.each do |mob|
        mob.action
        while event_packet = mob.shift_event
          @em.set_cut_in_event(event_packet.unpack(self))
        end
      end
      @do_action = false
    end

    def dash_move_mobs
      @mobs.each do |mob|
        mob.keep_prev
      end
    end

    def move_mobs
      all_updated = true
      dash = InputManager.down_dash?
      dash &= !InputManager.down_ok?
      @mobs.each do |mob|
        # 画面に含まれないモブは1フレームで移動を完了させる
        if !display_target?(mob) || dash
          mob.do_not_animation_move
        else
          mob.move
        end
        all_updated &= !mob.updating?
      end
      @waiting_update_complete = !all_updated
    end

    def update_mobs
      all_updated = true
      @mobs.each do |mob|
        mob.update
        all_updated &= !mob.updating?
      end
      @waiting_update_complete = !all_updated
    end

    #def update_mobs
    #  all_updated = true
    #  dash = InputManager.down_dash?
    #  @mobs.each do |mob|
    #    if !display_target?(mob) || dash
    #      mob.do_not_animation_move
    #    else
    #      mob.update
    #      mob.move
    #    end
    #    # 画面に含まれないモブは1フレームで移動を完了させる
    #    display_target?(mob) ? mob.update : mob.do_not_animation_move
    #    all_updated &= !mob.updating?
    #  end
    #  @waiting_update_complete = !all_updated
    #end

    def handle_input
      # 以下のキーハンドリングは上から順に優先度が高い。
      # どれかが有効に処理されたら他は無視される。
      [
       :handle_stamp,
       :handle_ok,
       :handle_input_xy,
      ].each do |handle|
        break if method(handle).call
      end

      while event_packet = @player.shift_event
        @em.set_cut_in_event(event_packet.unpack(self))
      end
    end

    # 決定ボタンの入力を制御する
    # 攻撃(素振り含む)に使われた場合のみターンを消費する
    def handle_ok
      if InputManager.push_ok?
        case @player.attack_or_check
        when :attack
          targets = @player.attack_target.values.flatten
          @player.attack_to(targets)
          targets.each do |target|
            # この時点でフロアから消しておくことで、直後のその他のモ
            # ブの行動で、死んだモブがいた場所に移動が可能になる
            @floor.remove_character(target.x, target.y) if target.dead?
          end
          tick
        when :check
        else
          # 素振り
          @player.swing
          tick
          # TODO: 罠の発見
        end
        true
      else
        false
      end
    end

    # 十字キーの入力を制御する
    # TODO: 現状は移動のみ。カーソルの移動などについても対応する
    def handle_input_xy
      res = false
      dx, dy = InputManager.get_input_xy
      return res if dx.zero? && dy.zero?

      res = true
      # TODO: ウィンドウ表示中か否かの分岐
      @player.change_direction_by_dxdy(dx, dy)

      return res if only_direction_change?
      return res if InputManager.down_diagonal? && !diagonally_move?(dx, dy)

      dash = InputManager.down_dash?
      cur_x, cur_y = @player.x, @player.y
      if @floor.movable?(cur_x, cur_y, cur_x + dx, cur_y + dy)
        @floor.move_character(cur_x, cur_y, cur_x + dx, cur_y + dy)
        tick
        if dash
          OutputManager.modify_map_offset(dx * TILE_WIDTH, dy * TILE_HEIGHT)
        else
          args = [self, dx * TILE_WIDTH, dy * TILE_HEIGHT]
          move_event = MoveEvent.create(*args)
          @em.set_cut_in_event(move_event)
        end
      end
      res
    end

    # 斜め移動かどうか
    def diagonally_move?(dx, dy)
      dx.abs == dy.abs
    end

    # 方向変更キーを押しているかどうか
    def only_direction_change?
      InputManager.down_option?
    end

    # 足踏みボタンの入力を制御する
    def handle_stamp
      if InputManager.down_stamp?
        3.times { @player.update }
        tick
        true
      end
      false
    end

    # 画面表示の対象かどうか、
    # 画面内に収まる場合はtrueをそうでない場合はfalseを返す
    def display_target?(obj)
      args = [obj.x * TILE_WIDTH, obj.y * TILE_HEIGHT, obj]
      OutputManager.display_target?(*args)
    end

    def display_palyer
      OutputManager.reserve_draw_center(@player)
    end

    def display_mobs
      @mobs.each do |mob|
        OutputManager.reserve_draw(mob.disp_x, mob.disp_y, mob, :character)
      end
    end

    def display_base_map
      @floor.each_tile do |x, y, tile|
        OutputManager.reserve_draw(x * TILE_WIDTH, y * TILE_HEIGHT, tile, :map)
      end
    end

    # TODO: メッセージウィンドウ表示の仕組みの変更
    #       現状では死んだモブに別のモブが重なるように移動してきてしまう
    def display_window
      if @message_window
        OutputManager.reserve_draw_message_window(@message_window)
        if @message_window.permanent?
        elsif @message_window.alive?
          @message_window.tick
        else
          @message_window = nil
        end
      end
    end

    def display_radar_map
      @floor.each_tile do |x, y, tile|
        if tile.any?
          any = tile.character || tile.object
          args = [x * RADAR_MAP_UNIT_SIZE, y * RADAR_MAP_UNIT_SIZE,
                  RADAR_MAP_IMAGES[any.type], :radar_map]
          OutputManager.reserve_draw_without_offset(*args)
        elsif tile.walkable?
          args = [x * RADAR_MAP_UNIT_SIZE, y * RADAR_MAP_UNIT_SIZE,
                  RADAR_MAP_IMAGES[:tile], :radar_map]
          OutputManager.reserve_draw_without_offset(*args)
        end
      end
    end
  end
end

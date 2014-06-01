module MyDungeonGame
  # 探索モードのシーン
  class ExplorationScene
    RADAR_MAP_IMAGES = {
      player: ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:player], RADAR_MAP_ALPHA[:player]),
      mob:    ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:mob], RADAR_MAP_ALPHA[:mob]),
      item:   ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:item], RADAR_MAP_ALPHA[:item]),
      stairs: ViewProxy.box(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                            RADAR_MAP_COLOR[:stairs], RADAR_MAP_ALPHA[:stairs]),
      tile:   ViewProxy.rect(RADAR_MAP_UNIT_SIZE, RADAR_MAP_UNIT_SIZE,
                             RADAR_MAP_COLOR[:tile], RADAR_MAP_ALPHA[:tile]),
    }.freeze

    attr_reader :player

    def initialize(storey=1, player=nil)
      extend(HelperMethods)
      @floor = DungeonManager.create_floor
      @floor.set_storey(storey)

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
      @mobs = create_mobs(@floor.storey)

      # アイテム、罠、階段の初期位置を決定
      @floor_objects = create_floor_objects(@floor.storey)

      # プレーヤーの初期位置を決定
      if player
        player.floor = @floor
        @player = player
      else
        @player = PlayerCharacter.new(@floor)
      end
      set_random_position(@player)
      @floor.searched(@player.x, @player.y)

      @menu_windows = []

      OutputManager.init(@player.x, @player.y)
      @em = EventManager.new(WaitInputEvent.create(self))
    end

    def create_mobs(storey)
      # TODO: 階に合わせた適切なNPC選択を行う
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

    def create_floor_objects(storey)
      res = []
      # TODO: 階に合わせた適切なフロアオブジェクト選択を行う
      items = [
               Kizugusuri,
               KaifukuNoKusuri,
               ChikaraNoKusuri,
               NikuMan,
               Sabel,
              ]
      5.times do
        item = items[DungeonManager.randomizer.rand(items.size)].new
        set_random_position(item)
        res << item
      end
      stairs = Stairs.new(@floor)
      set_random_position(stairs)
      res << stairs
      res
    end

    def set_random_position(obj)
      if obj.kind_of?(Character)
        set_character_random_position(obj)
      else
        set_floor_object_random_position(obj)
      end
    end

    def set_character_random_position(character)
      x, y = @floor.get_no_one_xy(DungeonManager.randomizer)
      character.x = x
      character.y = y
      character.prev_x = x
      character.prev_y = y
      retry_limit = 10
      while player_xy = @floor.get_room(x, y).player_xy
        # 見える範囲には出現させない
        break if !display_target?(character) || retry_limit <= 0
        x, y = @floor.get_no_one_xy(DungeonManager.randomizer)
        character.x = x
        character.y = y
        character.prev_x = x
        character.prev_y = y
        retry_limit -= 1
      end
      @floor[character.x, character.y].character = character
      true
    end

    def set_floor_object_random_position(fobj)
      x, y = @floor.get_no_one_xy(DungeonManager.randomizer)
      fobj.x = x
      fobj.y = y
      @floor[fobj.x, fobj.y].object = fobj
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
      display_floor_objects
      display_parameter
      display_radar_map
      display_window
      OutputManager.update
    end

    # ターンを消費する
    def tick
      @turn += 1
      @player.self_healing
      @player.hunger
      # TODO: 状態異常からの復帰など
      @do_action = true
      # 敵の増加
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
       :handle_menu,
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

    # メニューボタンの入力を制御する
    def handle_menu
      if InputManager.push_menu?
        mw = MainMenuWindow.new(make_menu_choices)
        @em.set_cut_in_event(ShowMenuEvent.create(self, mw))
      end
    end

    # メニューウインドウの選択肢を生成する
    def make_menu_choices
      # TODO: 「その他」イベントの設定
      iw = ItemWindow.new(@player.items)
      {
        MessageManager.get(:item) => lambda { ShowMenuEvent.create(self, iw) },
        MessageManager.get(:underfoot) => lambda { UnderfootEvent.create(self) },
        MessageManager.get(:map) => lambda { ClearMenuWindowEvent.create(self) },
        MessageManager.get(:other) => lambda { ClearMenuWindowEvent.create(self) },
      }
    end

    # 十字キーの入力を制御する
    def handle_input_xy
      res = false
      dx, dy = InputManager.get_input_xy
      return res if dx.zero? && dy.zero?

      res = true
      @player.change_direction_by_dxdy(dx, dy)

      return res if only_direction_change?
      return res if InputManager.down_diagonal? && !diagonally_move?(dx, dy)

      dash = InputManager.down_dash?
      cur_x, cur_y = @player.x, @player.y
      if @floor.movable?(cur_x, cur_y, cur_x + dx, cur_y + dy)
        @floor.move_character(cur_x, cur_y, cur_x + dx, cur_y + dy)
        @floor.searched(cur_x + dx, cur_y + dy)
        tick
        underfoot = @floor[cur_x + dx, cur_y + dy]
        if dash
          # ダッシュ中: アニメーションしない、アイテムの上に乗る
          OutputManager.modify_map_offset(dx * TILE_WIDTH, dy * TILE_HEIGHT)
          if underfoot.any_object? && underfoot.object.type == :item
            msg = MessageManager.get_on_item(underfoot.object.name)
            @em.set_cut_in_event(ShowMessageEvent.create(self, msg))
          end
        else
          # 歩行中: アニメーションする、アイテムを拾う
          args = [self, dx * TILE_WIDTH, dy * TILE_HEIGHT]
          move_event = MoveEvent.create(*args)
          if underfoot.any_object? && underfoot.object.type == :item
            if @player.get(underfoot.object)
              @floor_objects.delete(underfoot.object)
              underfoot.clear_object
            end
          end
          @em.set_cut_in_event(move_event)
        end
        check_stairs(cur_x + dx, cur_y + dy)
      end
      res
    end

    # 足元が階段の場合、降りるかどうかの判断を下す
    def check_stairs(x, y)
      underfoot = @floor[x, y]
      return if underfoot.no_object?
      if underfoot.object.type == :stairs
        @em.set_cut_in_event(GoToNextFloorEvent.create(self))
      end
    end

    def go_to_next_floor
      GeneralManager.next_floor(@floor, @player)
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
      [@player.weapon, @player.shield].compact.each do |equipment|
        equipment.x, equipment.y = @player.x, @player.y
        equipment.current_direction = @player.current_direction
        equipment.current_frame = @player.current_frame
        OutputManager.reserve_draw_center(equipment)
      end
    end

    def display_mobs
      @mobs.each do |mob|
        OutputManager.reserve_draw(mob.disp_x, mob.disp_y, mob, :character)
      end
    end

    # アイテム、罠、階段などの表示
    def display_floor_objects
      @floor_objects.each do |fobj|
        args = [fobj.x * TILE_WIDTH, fobj.y * TILE_HEIGHT, fobj, :object]
        OutputManager.reserve_draw(*args)
      end
    end

    def display_parameter
      OutputManager.reserve_draw_parameter(@floor.storey, @player)
    end

    def display_base_map
      @floor.each_tile do |x, y, tile|
        OutputManager.reserve_draw(x * TILE_WIDTH, y * TILE_HEIGHT, tile, :map)
      end
    end

    def display_window
      display_message_window
      display_yes_no_window
      display_menu_window
    end

    def display_message_window
      if @message_window
        OutputManager.reserve_draw_message_window(@message_window)
        # TTLが枯渇するまで一定時間表示する
        if @message_window.alive?
          @message_window.tick
        else
          @message_window = nil
        end
      end
    end

    def display_yes_no_window
      if @yes_no_window
        OutputManager.reserve_draw_yes_no_window(@yes_no_window)
      end
    end

    def display_menu_window
      @menu_windows.each do |window|
        OutputManager.reserve_draw_menu_window(window)
      end
    end

    def hide_radar_map?
      !!@yes_no_window ||
        @menu_windows.any?
    end

    # マップの表示
    def display_radar_map
      return if hide_radar_map?

      # 床の表示
      @floor.each_tile do |x, y, tile|
        if tile.walkable? && tile.searched?
          args = [x * RADAR_MAP_UNIT_SIZE, y * RADAR_MAP_UNIT_SIZE,
                  RADAR_MAP_IMAGES[:tile], :radar_map]
          OutputManager.reserve_draw_without_offset(*args)
        end
      end

      # アイテム、罠、階段の表示
      @floor_objects.each do |obj|
        if obj.searched?
          args = [obj.x * RADAR_MAP_UNIT_SIZE, obj.y * RADAR_MAP_UNIT_SIZE,
                  RADAR_MAP_IMAGES[obj.type], :radar_map]
          OutputManager.reserve_draw_without_offset(*args)
        end
      end

      # プレイヤーの表示
      args = [@player.x * RADAR_MAP_UNIT_SIZE, @player.y * RADAR_MAP_UNIT_SIZE,
              RADAR_MAP_IMAGES[:player], :radar_map]
      OutputManager.reserve_draw_without_offset(*args)

      # モブの表示
      vision = @player.visible_objects
      @mobs.each do |mob|
        if vision.include?(mob)
          args = [mob.x * RADAR_MAP_UNIT_SIZE, mob.y * RADAR_MAP_UNIT_SIZE,
                  RADAR_MAP_IMAGES[:mob], :radar_map]
          OutputManager.reserve_draw_without_offset(*args)
        end
      end
    end
  end
end

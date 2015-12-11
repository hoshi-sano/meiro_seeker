module MyDungeonGame
  # 探索モードのベース
  class BaseQuestScene
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

    def initialize(storey=1, player=nil, scene_info=nil)
      extend(HelperMethods) # see: lib/helper.rb
      @scene_info = scene_info
      if @scene_info
        @map_info = GeneralManager.map_data[@scene_info[:map_data_id]]
        if @map_info[:map_image_path]
          path = File.join(ROOT, 'data', @map_info[:map_image_path])
          @bg_map_image = FileLoadProxy.load_image(path)
        end
      end

      begin
        @floor = create_floor
      rescue Meiro::TrySeparateLimitError
        retry
      end
      @floor.set_storey(storey)

      # マップ名称
      if @map_info && @map_info[:name]
        @map_name = "#{storey} #{@map_info[:name]}"
      end

      # シーン切り替わり時の暗転継続時間
      @starting_break_time = STARTING_BREAK_TIME

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
      if @map_info && (initial_xy = @map_info[:player_initial_xy])
        # TODO: xy座標のバリデーション
        x, y = initial_xy[:x], initial_xy[:y]
        set_character_position(@player, x, y)
      else
        set_random_position(@player)
      end
      @floor.searched(@player.x, @player.y)

      @menu_windows = []

      OutputManager.init(@player.x, @player.y)
      @em = EventManager.new(WaitInputEvent.create(self))
    end

    # フロアを生成するためのメソッド
    # このメソッドは必ずoverrideすること
    def create_floor
      raise NotImplementedError
    end

    # フロアにプレーヤー以外のキャラクターを配置する場合はここをoverrideする
    def create_mobs(storey)
      []
    end

    # フロアにオブジェクトを配置する場合はここをoverrideする
    def create_floor_objects(storey)
      []
    end

    def set_position(obj, x, y)
      if obj.kind_of?(Character)
        set_character_position(obj, x, y)
      else
        set_floor_object_position(obj, x, y)
      end
    end

    def set_character_position(character, x, y)
      character.x = x
      character.y = y
      character.prev_x = x
      character.prev_y = y
      @floor[character.x, character.y].character = character
      true
    end

    def set_floor_object_position(fobj, x, y)
      fobj.x = x
      fobj.y = y
      @floor[fobj.x, fobj.y].object = fobj
      true
    end

    def set_random_position(obj)
      if obj.kind_of?(Character)
        set_character_random_position(obj)
      else
        set_floor_object_random_position(obj)
      end
    end

    # TODO: リファクタリング
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
      set_floor_object_position(fobj, x, y)
    end

    # アイテムの落下位置を決める。
    # 指定した座標に既に何かが落ちている場合は、周囲8マスのどこかに落下
    # させる。周囲8マスのどこにも落下候補がない場合はさらにその周囲のマ
    # スのどこかに落下させる。当初の指定座標から距離3マス以内に落下候補
    # がない場合は消える。
    def drop(item, x, y, dist=2)
      succeed = false
      return succeed if dist.zero?

      [y, (y-1), (y+1)].each do |cand_y|
        [x, (x-1), (x+1)].each do |cand_x|
          if @floor[cand_x, cand_y].puttable?
            item.x, item.y = cand_x, cand_y
            item.searched!
            @floor_objects << item
            @floor[item.x, item.y].object = item
            succeed = true
            break
          end
        end
        break if succeed
      end

      if !succeed
        [y, (y-1), (y+1)].each do |cand_y|
          [x, (x-1), (x+1)].each do |cand_x|
            if @floor[cand_x, cand_y].walkable?
              succeed = drop(item, cand_x, cand_y, dist-1)
            end
            break if succeed
          end
          break if succeed
        end
      end
      succeed
    end

    # 基本のループ処理
    def update
      # 暗転中はイベント処理しない
      if starting_break
        # 条件・状態によって変化するイベントを処理
        @em.do_event
      end

      # 毎フレームの必須イベントを処理
      display_base_map
      display_palyer
      display_mobs
      display_floor_objects
      display_parameter
      display_window
      OutputManager.update
    end

    # ターンを消費する
    def tick
      @turn += 1
      @do_action = true
    end

    # シーン切り替わり時の暗転 + マップ名表示
    def starting_break
      # TODO: 定数を使う
      if @starting_break_time >= 0
        t = @starting_break_time * 4
        alpha = ((t / 255) > 0) ? 255 : t
        OutputManager.blackout(alpha: alpha, map_name: @map_name)
        @starting_break_time -= 1
      end
      @starting_break_time < 40
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

    def handle_input
      # 以下のキーハンドリングは上から順に優先度が高い。
      # どれかが有効に処理されたら他は無視される。
      [
       :handle_stamp,
       :handle_ok,
       :handle_shot,
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
          # 対象を調べる、または対象との会話の発生
          target = @player.attack_target[:main]
          @player.check_on(target)
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

    # 射撃ボタンの入力を制御する
    def handle_shot
      return if !InputManager.push_shot?
      if @player.equip?(:bullet)
        args = [self, @player, @player.get_equipment(:bullet)]
        @em.set_cut_in_event(ShotEvent.create(*args))
      else
        msg = MessageManager.get(:no_bullet)
        @em.set_cut_in_event(ShowMessageEvent.create(self, msg))
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
      iw = ItemWindow.new(@player.items)
      smw = SubMenuWindow.new(make_sub_menu_choices)
      {
        MessageManager.get(:item) => lambda { ShowMenuEvent.create(self, iw) },
        MessageManager.get(:underfoot) => lambda { UnderfootEvent.create(self) },
        MessageManager.get(:map) => lambda {
          switch_radar_map
          ClearMenuWindowEvent.create(self)
        },
        MessageManager.get(:other) => lambda { ShowMenuEvent.create(self, smw) },
      }
    end

    # サブメニューウインドウの選択肢を生成する
    def make_sub_menu_choices
      # TODO: 中断、セーブなどの実装
      kcw = KeyConfigWindow.new(self)
      {
        MessageManager.get(:key_config) => lambda {
          ShowKeyConfigWindowEvent.create(self, kcw)
        },
        MessageManager.get(:save) => lambda { ClearMenuWindowEvent.create(self) },
        MessageManager.get(:break) => lambda { ClearMenuWindowEvent.create(self) },
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

    # 次のシーンを決める
    def next_scene
      DungeonScene
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

    # プレーヤーの表示を行う
    # 武器防具などのオプションを表示したい場合はoverrideする
    def display_palyer
      OutputManager.reserve_draw_center(@player)
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

    # 背景画像が決まっている場合はそれを、決まっていない場合はマップのタイルに応
    # じた画像を描画する
    def display_base_map
      if @bg_map_image
        OutputManager.reserve_draw_fixed_map_image(@bg_map_image)
      else
        @floor.each_tile_for_display(@player.x, @player.y) do |x, y, tile|
          OutputManager.reserve_draw(x * TILE_WIDTH, y * TILE_HEIGHT, tile, :map)
        end
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

    def switch_radar_map
      @hide_radar_map = !@hide_radar_map
    end

    def hide_radar_map?
      @hide_radar_map ||
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

    # Marshal.dump 不可能な要素を省く
    def before_save
      @bg_map_image = nil
      @em = nil
    end

    # Marshal.dump 後に必要な要素を再構築する
    def after_save
      if (@map_info || {})[:map_image_path]
        path = File.join(ROOT, 'data', @map_info[:map_image_path])
        @bg_map_image = FileLoadProxy.load_image(path)
      end
      @em = EventManager.new(WaitInputEvent.create(self))
    end

    # Marshal.load 後に必要な要素を再構築する
    def after_load
      after_save
      OutputManager.init(@player.x, @player.y)
    end
  end
end

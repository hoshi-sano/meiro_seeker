module MeiroSeeker
  # ダンジョンモードのシーン
  class DungeonScene < BaseQuestScene
    def create_floor
      DungeonManager.create_floor
    end

    def create_monster_table
      return nil unless @map_info[:monster_table]
      @monster_table = []
      @map_info[:monster_table].each do |k, v|
        next unless v.include?(@floor.storey)
        @monster_table << MeiroSeeker.const_get(k)
      end
      @monster_table
    end

    def monster_random_select
      return nil unless @monster_table
      idx = DungeonManager.randomizer.rand(@monster_table.size)
      @monster_table[idx].new(@floor)
    end

    def create_mobs(storey)
      # TODO: 敵以外のモブもランダムで出現させる？
      res = []
      room_num = @floor.all_rooms.size
      # TODO: 敵の数再考
      mob_num = DungeonManager.randomizer.rand(room_num) * 2
      mob_num = [room_num + 1, mob_num].max
      if create_monster_table
        mob_num.times do
          mob = monster_random_select
          set_random_position(mob)
          res << mob
        end
      end
      res
    end

    # 設定ファイルで指定されるアイテムと出現率をもとに、
    # ランダムアイテムテーブルを作成する
    # NOTE: 出現する階層も指定できた方がよいかもしれない
    # TODO: 罠にも対応する
    def create_floor_object_table
      return nil unless @map_info[:item_table]
      @item_table = {}
      rate_counter = 0
      @map_info[:item_table].each do |k, v|
        item_klass = MeiroSeeker.const_get(k)
        @item_table[item_klass] = (rate_counter...(rate_counter + v))
        rate_counter += v
      end
      @item_table
    end

    # 出現率に基づいてアイテムテーブルからアイテムをランダムで返す
    def item_random_select
      return nil unless @item_table
      _, last_item_range = @item_table.to_a.last
      max_counter = last_item_range.last
      v = DungeonManager.randomizer.rand(max_counter)
      res = nil
      @item_table.each do |item_klass, range|
        if range.include?(v)
          res = item_klass.new
          break
        end
      end
      res
    end

    def create_floor_objects(storey)
      res = []
      create_floor_object_table
      if @item_table
        # 1フロアのアイテム数は3~5個
        item_num = DungeonManager.randomizer.rand(3) + 3
        item_num.times do
          item = item_random_select
          set_random_position(item)
          res << item
        end
      end
      stairs = Stairs.new(@floor)
      set_random_position(stairs)
      res << stairs
      # TODO: 罠の設置
      res
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
      display_player
      display_mobs
      display_floor_objects
      display_parameter
      display_radar_map
      display_window
      OutputManager.update
      @do_dash = false
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
        mob = monster_random_select
        set_random_position(mob)
        @mobs << mob
      end
    end

    def display_player
      super
      [@player.weapon, @player.shield].compact.each do |equipment|
        equipment.x, equipment.y = @player.x, @player.y
        equipment.current_direction = @player.current_direction
        equipment.current_frame = @player.current_frame
        OutputManager.reserve_draw_center(equipment)
      end
    end
  end
end

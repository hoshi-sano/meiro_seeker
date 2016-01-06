module MyDungeonGame
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
        @monster_table << MyDungeonGame.const_get(k)
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

    def create_floor_objects(storey)
      res = []
      # TODO: 階に合わせた適切なフロアオブジェクト選択を行う
      items = [
               Kizugusuri,
               KaifukuNoKusuri,
               ChikaraNoKusuri,
               ConfusionPotion,
               NikuMan,
               Sabel,
               GhostBuster,
               IronShield,
               HungryShield,
               AntiHungryShield,
               LightRing,
               CalmRing,
               NormalBullet,
               ThunderGrimoire,
               LightGrimoire,
               ConfusionGrimoire,
               WeaponEnhancementGrimoire,
               ShieldEnhancementGrimoire,
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

    def display_palyer
      OutputManager.reserve_draw_center(@player)
      [@player.weapon, @player.shield].compact.each do |equipment|
        equipment.x, equipment.y = @player.x, @player.y
        equipment.current_direction = @player.current_direction
        equipment.current_frame = @player.current_frame
        OutputManager.reserve_draw_center(equipment)
      end
    end
  end
end

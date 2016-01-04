module MyDungeonGame
  # ダンジョンモードのシーン
  class DungeonScene < BaseQuestScene
    def create_floor
      DungeonManager.create_floor
    end

    def create_mobs(storey)
      # TODO: 階に合わせた適切なNPC選択を行う
      res = []
      room_num = @floor.all_rooms.size
      # TODO: 敵の数再考
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
               ConfusionPotion,
               NikuMan,
               Sabel,
               GhostBuster,
               IronShield,
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

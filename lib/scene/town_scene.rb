module MyDungeonGame
  # 街モードのシーン
  class TownScene < BaseQuestScene
    def create_floor
      DungeonManager.create_town_floor(@map_info[:map_data])
    end

    def create_mobs(storey)
      res = []
      @map_info[:characters].each do |mob_info|
        mob = MyDungeonGame.const_get(mob_info[:class]).new(@floor)
        set_position(mob, mob_info[:x], mob_info[:y])
        mob.messages = mob_info[:messages] if mob_info[:messages]
        res << mob
      end
      res
    end

    def create_floor_objects(storey)
      res = []
      @map_info[:objects].each do |obj_info|
        obj = MyDungeonGame.const_get(obj_info[:class]).new(@floor)
        set_position(obj, obj_info[:x], obj_info[:y])
        res << obj
      end
      res
    end

    def next_scene
      # TODO: ダンジョンの構成によって分岐できるようにする
      DungeonScene
    end
  end
end

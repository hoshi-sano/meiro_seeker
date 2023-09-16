module MeiroSeeker
  # 街モードのシーン
  class TownScene < BaseQuestScene
    def create_floor
      DungeonManager.create_town_floor(@map_info[:map_data])
    end

    def create_mobs(storey)
      res = []
      (@map_info[:characters] || []).each do |mob_info|
        mob = MeiroSeeker.const_get(mob_info[:class]).new(@floor)
        set_position(mob, mob_info[:x], mob_info[:y])
        mob.generate_event_manager(mob_info[:events]) if mob_info[:events]
        res << mob
      end
      res
    end

    def create_floor_objects(storey)
      res = []
      (@map_info[:objects] || []).each do |obj_info|
        obj = MeiroSeeker.const_get(obj_info[:class]).new(@floor)
        set_position(obj, obj_info[:x], obj_info[:y])
        if (obj.type == :stairs) && (obj_info[:next_scene_id])
          obj.next_scene_id = obj_info[:next_scene_id]
        end
        res << obj
      end
      res
    end
  end
end

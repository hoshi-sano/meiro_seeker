MeiroSeeker::SCENES = {:initial_scene=>
  {:scene_class=>"TitleScene", :next_scene_id=>:start_town_scene},
 :start_town_scene=>
  {:storey=>1, :scene_class=>"TownScene", :map_data_id=>:town_00},
 :first_dungeon=>{:scene_class=>"DungeonScene", :map_data_id=>:first_dungeon},
 :second_dungeon=>
  {:scene_class=>"DungeonScene", :map_data_id=>:second_dungeon}}

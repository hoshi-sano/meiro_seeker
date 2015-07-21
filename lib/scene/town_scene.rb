module MyDungeonGame
  # 街モードのシーン
  class TownScene < BaseQuestScene
    def initialize
      # TODO: yaml などから path を取ってこれるようにする
      path = File.join(ROOT, 'data', 'town00.png')
      @bg_map_image = FileLoadProxy.load_image(path)
      super
    end

    def create_floor
      DungeonManager.create_town_floor
    end

    def create_mobs(storey)
      res = []
      # TODO: 階に合わせた適切なモブの生成
      mob = IntelligentCharacter.new(@floor)
      set_position(mob, 5, 4)
      res << mob
      res
    end

    def create_floor_objects(storey)
      res = []
      # TODO: 画像なしの階段を使えるようにする
      stairs = Stairs.new(@floor)
      # TODO: 街の適切な階段の座標を利用する
      set_position(stairs, 5, 3)
      res << stairs
      res
    end

    def next_scene
      # TODO: ダンジョンの構成によって分岐できるようにする
      DungeonScene
    end

    # 1枚の画像でマップを表示する
    def display_base_map
      OutputManager.reserve_draw_fixed_map_image(@bg_map_image)
    end
  end
end

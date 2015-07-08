module MyDungeonGame
  # 街モードのシーン
  class TownScene < BaseQuestScene
    def create_floor
      DungeonManager.create_town_floor
    end

    def create_mobs(storey)
      res = []
      # TODO: モブの生成
      res
    end

    def create_floor_objects(storey)
      res = []
      # TODO: 画像なしの階段を使えるようにする
      stairs = Stairs.new(@floor)
      # TODO: 街の適切な階段の座標を利用する
      set_random_position(stairs)
      res << stairs
      res
    end

    def next_scene
      # TODO: ダンジョンの構成によって分岐できるようにする
      DungeonScene
    end
  end
end

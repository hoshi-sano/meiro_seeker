module MyDungeonGame
  # 階段クラス
  class Stairs < FloorObject
    type :stairs
    image FileLoadProxy.load_image(STAIRS_IMAGE_PATH)

    def initialize(floor)
      super()
      @floor = floor
    end
  end
end

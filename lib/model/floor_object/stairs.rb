module MyDungeonGame
  # 階段クラス
  class Stairs < FloorObject
    type :stairs
    image FileLoadProxy.load_image(STAIRS_IMAGE_PATH)

    attr_accessor :storey_add_value

    def initialize(floor)
      super()
      @floor = floor
      @storey_add_value = 1
    end
  end
end

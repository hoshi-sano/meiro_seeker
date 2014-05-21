module MyDungeonGame
  class Item < FloorObject
    class << self
      def name(value)
        @name = value
      end

      def get_name
        @name || "BaseItem"
      end
    end

    type :item
    image FileLoadProxy.load_image(STAIRS_IMAGE_PATH)

    attr_reader :name

    def initialize(floor)
      super()
      @name = self.class.get_name
    end

    def event
      # 空イベント
      Event.new {|e| e.finalize }
    end
  end
end

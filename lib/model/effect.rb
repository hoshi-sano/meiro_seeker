module MeiroSeeker
  # 魔導書や特殊攻撃のエフェクトの基本クラス
  class Effect
    class << self
      def pattern_x(value)
        @pattern_x = value
      end

      def get_pattern_x
        @pattern_x
      end

      def pattern_y(value)
        @pattern_y = value
      end

      def get_pattern_y
        @pattern_y
      end

      def image_path(value)
        @image_path = value
        args = [@image_path, @pattern_x, @pattern_y]
        @images = FileLoadProxy.load_image_tiles(*args)
      end

      def images
        @images
      end

      def update_interval(value)
        @update_interval = value
      end

      def get_update_interval
        @update_interval || 10
      end
    end

    attr_reader :current_frame

    def initialize
      @current_frame = 0
      @current_direction = CHARACTER_DIRECTION[:S]
    end

    def image
      self.class.images[@current_direction][@current_frame]
    end

    def width
      self.class.images[@current_direction][@current_frame].width
    end

    def height
      self.class.images[@current_direction][@current_frame].height
    end

    def update_interval
      self.class.get_update_interval
    end

    def change_direction(direction)
      if CHARACTER_DIRECTION.keys.include?(direction)
        @current_direction = CHARACTER_DIRECTION[direction]
      end
    end

    def rewind
      @current_frame = 0
    end

    def update
      @current_frame += 1 if update? && !finished?
    end

    def update?
      @next_update ||= update_interval
      @next_update -= 1
      if @next_update <= 0
        @next_update = update_interval
        true
      else
        false
      end
    end

    def finished?
      @current_frame >= self.class.get_pattern_x
    end
  end
end

require_remote "lib/model/effect/flash_effect.rb"
require_remote "lib/model/effect/light_effect.rb"
require_remote "lib/model/effect/thunder_effect.rb"
require_remote "lib/model/effect/weapon_enhancement_effect.rb"

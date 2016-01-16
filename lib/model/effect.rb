module MyDungeonGame
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

    def initialize
      @current_frame = 0
      @current_direction = CHARACTER_DIRECTION[:S]
    end

    def image
      self.class.images[@current_direction][@current_frame]
    end

    def width
      self.class.images.first.first.width
    end

    def height
      self.class.images.first.first.height
    end

    def update_interval
      self.class.get_update_interval
    end

    def change_direction(direction)
      if CHARACTER_DIRECTION.keys.include?(direction)
        @current_direction = CHARACTER_DIRECTION[direction]
      end
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

# load effect dir
here = File.dirname(File.expand_path(__FILE__))
effect_dir = File.join(here, "effect")
Dir.entries(effect_dir).each do |fname|
  if fname =~ /\.rb$/
    require File.join(effect_dir, fname)
  end
end

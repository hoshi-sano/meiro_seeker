module MyDungeonGame
  # 魔導書の基本となるクラス
  class Grimoire < Item
    RANGE_TYPES = [
      :only_player,
      :surroundings,
      :room,
    ]

    type   :item
    image  IMAGES[:potion] # TODO: 魔導書用の画像を用意する

    class << self
      def get_type
        if self == Grimoire
          super
        else
          Grimoire.get_type
        end
      end

      def range_type(val)
        raise MustNotHappen, self unless RANGE_TYPES.include?(val)
        @range_type = val
      end
    end

    def image
      Grimoire.default_image
    end

    def order
      ORDER[:grimoire]
    end

    def range
      self.class.instance_variable_get(:@range_type)
    end

    # 対象となるキャラクターを配列で返す
    def target_characters(scene)
      case range
      when :only_player
        scene.player
      when :surroundings
        scene.player.surrounding_objects.select do |o|
          o.kind_of?(Character) && o.type != :player
        end
      when :room
        scene.player.visible_objects.select do |o|
          o.kind_of?(Character) && o.type != :player
        end
      else
        []
      end
    end
  end
end

module MeiroSeeker
  # フロアに落ちているもの、設置されているものの基本クラス
  # （アイテム、階段、罠など）
  class FloorObject
    class << self
      def type(value)
        @type = value
      end

      def get_type
        @type || :item
      end

      def image(value)
        @image = value
      end

      def default_image
        @image
      end
    end

    attr_reader :image, :type
    attr_accessor :x, :y, :searched

    def initialize
      @type = self.class.get_type
      @searched = false
    end

    def image
      self.class.default_image
    end

    def width
      image.width
    end

    def height
      image.height
    end

    def searched?
      !!@searched
    end

    def searched!
      @searched = true
    end
  end
end

require_remote "lib/model/floor_object/stairs.rb"
require_remote "lib/model/floor_object/transparent_stairs.rb"
require_remote "lib/model/floor_object/item.rb"
require_remote "lib/model/floor_object/item/equipment.rb"
require_remote "lib/model/floor_object/item/weapon.rb"
require_remote "lib/model/floor_object/item/shield.rb"
require_remote "lib/model/floor_object/item/ring.rb"
require_remote "lib/model/floor_object/item/bullet.rb"
# 武器
require_remote "lib/model/floor_object/item/sabel.rb"
require_remote "lib/model/floor_object/item/ghost_buster.rb"
# 盾
require_remote "lib/model/floor_object/item/iron_shield.rb"
require_remote "lib/model/floor_object/item/hungry_shield.rb"
require_remote "lib/model/floor_object/item/anti_hungry_shield.rb"
require_remote "lib/model/floor_object/item/anti_steal_shield.rb"
# リング
require_remote "lib/model/floor_object/item/light_ring.rb"
require_remote "lib/model/floor_object/item/calm_ring.rb"
# 弾
require_remote "lib/model/floor_object/item/normal_bullet.rb"
# 薬
require_remote "lib/model/floor_object/item/potion.rb"
require_remote "lib/model/floor_object/item/hp_recover_item.rb"
require_remote "lib/model/floor_object/item/kizugusuri.rb"
require_remote "lib/model/floor_object/item/kaifuku_no_kusuri.rb"
require_remote "lib/model/floor_object/item/chikara_no_kusuri.rb"
require_remote "lib/model/floor_object/item/confusion_potion.rb"
require_remote "lib/model/floor_object/item/warp_potion.rb"
require_remote "lib/model/floor_object/item/speed_up_potion.rb"
# まんじゅう
require_remote "lib/model/floor_object/item/manju.rb"
require_remote "lib/model/floor_object/item/mantou.rb"
require_remote "lib/model/floor_object/item/niku_man.rb"
# 魔導書
require_remote "lib/model/floor_object/item/grimoire.rb"
require_remote "lib/model/floor_object/item/confusion_grimoire.rb"
require_remote "lib/model/floor_object/item/thunder_grimoire.rb"
require_remote "lib/model/floor_object/item/light_grimoire.rb"
require_remote "lib/model/floor_object/item/weapon_enhancement_grimoire.rb"
require_remote "lib/model/floor_object/item/shield_enhancement_grimoire.rb"

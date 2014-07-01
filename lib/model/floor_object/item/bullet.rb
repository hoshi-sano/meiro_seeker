module MyDungeonGame
  # 弾の基本となるクラス
  class Bullet < Equipment
    TYPE = :bullet

    def initialize(num=nil)
      super()
      @calibration = num || DungeonManager.randomizer.rand(15) + 5
    end

    def got_by(getter)
      if idx = getter.items.map(&:class).index(self.class)
        # 同じ種類を既に持っている場合はマージする
        getter.items[idx].merge(self)
      else
        getter.items << self
      end
    end

    def merge(other)
      self.calibration += other.calibration
      self.calibration = MAX_CALIBRATION if self.calibration > MAX_CALIBRATION
    end

    def divide(num)
      raise if num > @calibration
      @calibration -= num
      self.class.new(num)
    end

    def name
      [@calibration, @name].join
    end

    def order
      if self.equipped?
        ORDER[:equipped_bullet]
      else
        ORDER[:bullet]
      end
    end

    # 基本性能
    def strength
      @base_strength
    end

    def item_menu_choices(scene)
      if self.equipped?
        choices = {MENU_WORDS[:remove] => lambda { self.remove_event(scene) }}
      else
        choices = {MENU_WORDS[:equip] => lambda { self.equip_event(scene) }}
      end
      rest = {
        MENU_WORDS[:shot] => lambda { ShotEvent.create(scene, scene.player, self) },
        MENU_WORDS[:put]  => lambda { PutItemEvent.create(scene, self) },
        MENU_WORDS[:note] => lambda { ShowItemNoteEvent.create(scene, self) },
      }
      choices.merge!(rest)
      choices
    end

    def underfoot_menu_choices(scene)
      {
        MENU_WORDS[:get]  => get_from_underfoot_proc(scene),
        MENU_WORDS[:shot] => lambda { ShotEvent.create(scene, scene.player, self) },
        MENU_WORDS[:note] => lambda { ShowItemNoteEvent.create(scene, self) },
      }
    end

    def calc_base_hit_damage
      self.strength
    end
  end
end

module MyDungeonGame
  # 装備品の基本となるクラス
  class Equipment < Item
    class << self
      def base_strength(value)
        @base_strength = value
      end

      def get_base_strength
        @base_strength || 0
      end

      def equipped_image_path(value)
        @equipped_image_path = value
      end

      def get_equipped_image_path
        @equipped_image_path
      end
    end

    EQUIPPED_SIGN = 'E'

    attr_reader   :base_strength, :equipped_image_path
    attr_accessor :equipped_by, :calibration

    def initialize
      super
      @equipped_by = nil
      @calibration = 0
      @base_strength = self.class.get_base_strength
      @equipped_image_path = self.class.get_equipped_image_path
    end

    # 補正値付きの名前の文字列を返す
    def name
      res = super()
      if !@calibration.zero?
        calib = ((@calibration > 0) ? '+' : '-') + (@calibration.abs.to_s)
        res += calib
      end
      res
    end

    # アイテムウインドウ内での表示名
    # 装備済みの場合は先頭に装備マークを付ける
    # TODO: その他の記号対応
    def display_name
      self.equipped? ? "#{EQUIPPED_SIGN}#{self.name}" : self.name
    end

    def equipment_type
      self.class::TYPE
    end

    # 誰かに装備されているか否か
    def equipped?
      !!@equipped_by
    end

    # 装備を外された場合に呼ばれる
    def removed!
      @equipped_by.remove_equipment(self.equipment_type)
      @equipped_by = nil
    end

    def menu_event(scene)
      if self.equipped?
        choices = {MENU_WORDS[:remove] => lambda { self.remove_event(scene) }}
      else
        choices = {MENU_WORDS[:equip] => lambda { self.equip_event(scene) }}
      end
      rest = {
        MENU_WORDS[:throw] => lambda { ClearMenuWindowEvent.create(scene) },
        MENU_WORDS[:put]   => lambda { PutItemEvent.create(scene, self) },
        MENU_WORDS[:note]  => lambda { ShowItemNoteEvent.create(scene, self) },
      }
      choices.merge!(rest)

      item_menu_window = ItemMenuWindow.new(choices)
      ShowMenuEvent.create(scene, item_menu_window)
    end

    def equip_event(scene)
      EquipEvent.create(scene, self)
    end

    def remove_event(scene)
      RemoveEquipmentEvent.create(scene, self)
    end
  end
end
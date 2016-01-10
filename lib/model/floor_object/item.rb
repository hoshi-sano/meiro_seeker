module MyDungeonGame
  # アイテムの基本となるクラス
  class Item < FloorObject
    class << self
      def name(value)
        @name = value
      end

      def get_name
        @name || "BaseItem"
      end

      def note(value)
        @note = value
      end

      def get_note
        @note || "note"
      end
    end

    MENU_WORDS = {
      get:    MessageManager.get('items.menu.get'),
      use:    MessageManager.get('items.menu.use'),
      equip:  MessageManager.get('items.menu.equip'),
      remove: MessageManager.get('items.menu.remove'),
      throw:  MessageManager.get('items.menu.throw'),
      shot:   MessageManager.get('items.menu.shot'),
      put:    MessageManager.get('items.menu.put'),
      note:   MessageManager.get('items.menu.note'),
    }
    IMAGES = {
      weapon: FileLoadProxy.load_image(WEAPON_IMAGE_PATH),
      shield: FileLoadProxy.load_image(SHIELD_IMAGE_PATH),
      ring:   FileLoadProxy.load_image(RING_IMAGE_PATH),
      bullet: FileLoadProxy.load_image(BULLET_IMAGE_PATH),
      potion: FileLoadProxy.load_image(POTION_IMAGE_PATH),
      manju: FileLoadProxy.load_image(MANJU_IMAGE_PATH),
      grimoire: FileLoadProxy.load_image(GRIMOIRE_IMAGE_PATH),
    }
    ORDER = {
      equipped_weapon: -400,
      equipped_shield: -300,
      equipped_ring:   -200,
      equipped_bullet: -100,
      weapon:   100,
      shield:   200,
      ring:     300,
      bullet:   400,
      manju:    500,
      potion:   600,
      grimoire: 700,
      other:    999,
    }


    type :item
    image IMAGES[:potion]

    attr_reader :name, :note

    def initialize
      super()
      @name = self.class.get_name
      @note = self.class.get_note
    end

    # アイテムによって取得時の挙動が変わるため(弾丸やお金はまとめあげら
    # れる)、取得処理をアイテム側に持たせる
    def got_by(getter)
      getter.items << self
    end

    # アイテムウインドウ内での表示名
    def display_name
      @name
    end

    # 誰かに装備されているか否か
    # 装備品でない場合は必ずfalseを返す
    def equipped?
      false
    end

    def event
      ClearMenuWindowEvent.create(@scene)
    end

    def show_item_menu_event(scene, choices)
      item_menu_window = ItemMenuWindow.new(choices)
      ShowMenuEvent.create(scene, item_menu_window)
    end

    # アイテム欄から選択された際に表示するメニュー
    def menu_event(scene)
      choices = item_menu_choices(scene)
      show_item_menu_event(scene, choices)
    end

    def item_menu_choices(scene)
      {
        MENU_WORDS[:use]   => lambda { self.use_event(scene) },
        MENU_WORDS[:throw] => lambda { ItemThrowEvent.create(scene, scene.player, self) },
        MENU_WORDS[:put]   => lambda { PutItemEvent.create(scene, self) },
        MENU_WORDS[:note]  => lambda { ShowItemNoteEvent.create(scene, self) },
      }
    end

    # 足元から選択された際に表示するメニュー
    def underfoot_event(scene)
      choices = underfoot_menu_choices(scene)
      show_item_menu_event(scene, choices)
    end

    def underfoot_menu_choices(scene)
      {
        MENU_WORDS[:get]   => get_from_underfoot_proc(scene),
        MENU_WORDS[:use]   => lambda { self.use_event(scene) },
        MENU_WORDS[:throw] => lambda { ItemThrowEvent.create(scene, scene.player, self) },
        MENU_WORDS[:note]  => lambda { ShowItemNoteEvent.create(scene, self) },
      }
    end

    # TODO: scene側のメソッドにする
    def get_from_underfoot_proc(scene)
      lambda {
        scene.instance_eval do
          underfoot = @floor[@player.x, @player.y]
          if @player.get(underfoot.object)
            @floor_objects.delete(underfoot.object)
            underfoot.clear_object
          end
        end
        ClearMenuWindowEvent.create(scene)
      }
    end

    # アイテム欄から選択して「使う」を実行した場合のイベント
    def use_event(scene)
      # 全ウインドウの消去
      e = ClearMenuWindowEvent.create(scene)
      # 使用した旨のメッセージの表示
      e.set_next(ShowMessageEvent.create(scene, use_message(scene.player.name)))
      # アイテム使用演出
      e.set_next(use_action_event(scene))
      # 効果
      e.set_next(effect_event(scene))
      # ターン経過
      e.set_next(Event.new { |e| scene.instance_eval { tick; e.finalize } })
      e
    end

    def use_message(player_name)
      MessageManager.player_use_item(player_name, @name)
    end

    def use_action_event(scene)
      item = self
      scene.instance_eval do
        Event.new do |e|
          # プレイヤーのアイテム欄にある場合
          deleted = @player.items.delete(item)
          if deleted.nil?
            # プレイヤーの足元にある場合
            @floor_objects.delete(@floor[@player.x, @player.y].object)
            @floor[@player.x, @player.y].clear_object
          end
          e.finalize
        end
      end
    end

    def effect_event(scene)
      Event.new {|e| e.finalize }
    end

    def hit_event(scene, thrower, target)
      msg = MessageManager.item_hit_to(self.name, target.name)
      ShowMessageEvent.create(scene, msg)
    end

    def with_death_check(scene, attacker, target, &block)
      e = yield(scene, attacker, target)
      scene.instance_eval do
        if target.dead?
          kill = Event.new do |e|
            attacker.kill(target)
            # TODO: プレイヤーの死を実装したら以下のif文を削る
            if target.type != :player
              @floor.remove_character(target.x, target.y)
            end
            e.finalize
          end
          e.set_next(kill)
        end

        judge = Event.new do |e|
          # killメソッドによってattackerの@eventsにpackしたイベントが登
          # 録されるため、それを直ちに実行すべく展開してcut_inする
          while event_packet = attacker.pop_event
            e.set_next_cut_in(event_packet.unpack(self))
          end
          e.finalize
        end
        e.set_next(judge)
      end
      e
    end

    def order
      ORDER[:other]
    end

    def <=>(other)
      res = self.order <=> other.order
      if res.zero?
        res = self.class.to_s <=> other.class.to_s
      end
      res
    end
  end
end


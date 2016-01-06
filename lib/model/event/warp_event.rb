module MyDungeonGame
  # ワープイベント
  module WarpEvent
    module_function

    def create(scene, target, to=nil)
      scene.instance_eval do
        # 連続ワープを防ぐためにワープ済みフラグを立てる
        target.warped = true

        before = [target.x, target.y]
        dummy = target.display_dummy
        # ワープ演出
        first_event = Event.new(if_alive: target) do |e|
          target.hide
          args = [before[0] * TILE_WIDTH, before[1] * TILE_WIDTH]
          OutputManager.reserve_draw(*args, dummy, :character)
          e.finalize
        end
        5.times do |i|
          args = [before[0] * TILE_WIDTH, (before[1] - i) * TILE_WIDTH]
          first_event.set_next(
            Event.new { |e|
              OutputManager.reserve_draw(*args, dummy, :character)
              e.finalize
            })
        end
        # ワープの実行
        # NOTE: 本来はイベント内ではなく、create時点で
        #       位置の移動を実行すべきかも
        pos_change = Event.new do |e|
          target.show
          if to.nil?
            # ランダムワープ
            @floor.remove_character(target)
            set_character_random_position(target)
            if target == @player
              @floor.searched(@player.x, @player.y)
              OutputManager.init(@player.x, @player.y)
            end
          else
            # TODO: 特定の場所へのワープ
            raise MustNotHappen
          end
          e.finalize
        end
        first_event.set_next(pos_change)
        msg = MessageManager.warped(target.name)
        msg_event = ShowMessageEvent.create(self, msg)
        first_event.set_next(msg_event)
        first_event
      end
    end
  end
end

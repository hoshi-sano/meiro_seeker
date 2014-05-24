module MyDungeonGame
  module PutItemEvent
    module_function

    def create(scene, item)
      scene.instance_eval do
        clear_menu = ClearMenuWindowEvent.create(scene)

        put_item = Event.new do |e|
          if @floor[@player.x, @player.y].puttable?
            @player.items.delete(item)
            item.x = @player.x
            item.y = @player.y
            @floor[@player.x, @player.y].object = item
            @floor_objects << item
            put = true
          end

          if put
            msg = MessageManager.put_item(item.name)
          else
            msg = MessageManager.get(:cannot_put_item)
          end
          e.set_next_cut_in(ShowMessageEvent.create(self, msg))
          e.finalize
        end
        clear_menu.set_next(put_item)

        clear_menu
      end
    end
  end
end

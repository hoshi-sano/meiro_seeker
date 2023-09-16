module MeiroSeeker
  module ShowStartMenuEvent
    module_function

    def create(scene)
      scene.instance_eval do
        Event.new do |e|
          if @menu_windows.empty?
            gsw = GameStartingWindow.new(@choices)
            @em.set_cut_in_event(ShowMenuEvent.create(self, gsw))
          end
        end
      end
    end
  end
end

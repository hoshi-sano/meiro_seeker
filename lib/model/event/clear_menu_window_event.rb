module MeiroSeeker
  # メニューウインドウ非表示イベント
  module ClearMenuWindowEvent
    module_function

    def create(scene)
      scene.instance_eval do
        Event.new do |e|
          @message_window.set_ttl(0) if @message_window
          @menu_windows.clear
          e.finalize
        end
      end
    end
  end
end

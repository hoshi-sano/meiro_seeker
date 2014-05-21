module MyDungeonGame
  # メニューウインドウ非表示イベント
  module ClearMenuWindowEvent
    module_function

    def create(scene)
      scene.instance_eval do
        Event.new do |e|
          @menu_windows.clear
          e.finalize
        end
      end
    end
  end
end

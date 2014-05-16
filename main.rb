$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'dxruby'
require 'my_dungeon_game'

Window.fps = 30
Window.loop do
  MyDungeonGame.play
end

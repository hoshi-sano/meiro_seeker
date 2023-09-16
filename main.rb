$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'dxruby'
require 'meiro_seeker'

Window.fps = 30
Window.loop do
  MeiroSeeker.play
end

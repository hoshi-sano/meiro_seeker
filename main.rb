require "dxopal"
include DXOpal

require_remote "lib/meiro_seeker.rb"

Window.fps = 30
Window.loop do
  MeiroSeeker.play
end

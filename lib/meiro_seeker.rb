# フレームワーク用ライブラリ
require 'constants'
require 'error'
require 'proxy'
require 'manager'
require 'model'
require 'scene'
require 'helper'

# ゲームデータライブラリ
require 'meiro'
require 'my_tile'

module MeiroSeeker
  module_function

  def play
    GeneralManager.play
  end
end

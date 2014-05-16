# フレームワーク用ライブラリ
require 'constants'
require 'proxy'
require 'model'
require 'manager'
require 'scene'
require 'helper'

# ゲームデータライブラリ
require 'meiro'
require 'my_tile'

module MyDungeonGame
  module_function

  def play
    GeneralManager.play
  end
end

# フレームワーク用ライブラリ
require_remote "lib/constants.rb"
require_remote "lib/error.rb"
require_remote "lib/proxy.rb"
require_remote "lib/manager.rb"
require_remote "lib/model.rb"
require_remote "lib/scene.rb"
require_remote "lib/helper.rb"

# ゲームデータライブラリ
require 'meiro'
require 'my_tile'

module MeiroSeeker
  module_function

  def play
    GeneralManager.play
  end
end

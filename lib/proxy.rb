# 将来的に dxruby 以外のライブラリも利用可能とする場合、
# proxy 以下の書き換えだけで互換を保てるようにするためのファイル郡
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'proxy'))

require 'file_load_proxy'
require 'view_proxy'
require 'input_proxy'
require 'font_proxy'

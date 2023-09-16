# 将来的に dxruby 以外のライブラリも利用可能とする場合、
# proxy 以下の書き換えだけで互換を保てるようにするためのファイル郡
require_remote "lib/proxy/file_load_proxy.rb"
require_remote "lib/proxy/view_proxy.rb"
require_remote "lib/proxy/input_proxy.rb"
require_remote "lib/proxy/font_proxy.rb"

module MeiroSeeker
  # 透明階段クラス
  # 階数を先に進めずにマップチェンジしたい場合、先に進む際の質問文を
  # 変更したい場合等に利用する
  class TransparentStairs < Stairs
    type :stairs
    image ViewProxy.rect([TILE_WIDTH, TILE_HEIGHT],
                         TRANSPARENT[:color], TRANSPARENT[:alpha]).image

    def initialize(floor)
      super
      @storey_add_value = 0
    end
  end
end

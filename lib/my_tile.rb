file_path = File.join(MyDungeonGame::ROOT, 'data', 'floor.png')
# TODO: flatten を使ってるのがダサいのでなんとかする
IMAGES = MyDungeonGame::FileLoadProxy.load_image_tiles(file_path, 8, 6).flatten

TILE_IMAGE_KEY_MAP = {
  1 => 28,
  2 => 19,
  3 => 29,
  4 => 24,
  6 => 25,
  7 => 30,
  8 => 26,
  9 => 31,
  13 => 6,
  16 => 41,
  17 => 7,
  18 => 47,
  19 => 31,
  24 => 11,
  26 => 16,
  27 => 39,
  28 => 10,
  29 => 37,
  34 => 33,
  37 => 30,
  38 => 45,
  39 => 14,
  46 => 3,
  48 => 18,
  49 => 34,
  67 => 42,
  68 => 17,
  79 => 15,
  137 => 23,
  138 => 46,
  139 => 22,
  167 => 40,
  168 => 44,
  179 => 21,
  246 => 8,
  248 => 2,
  249 => 35,
  267 => 36,
  268 => 1,
  279 => 38,
  348 => 43,
  349 => 32,
  379 => 20,
  468 => 9,
  1379 => 5,
  2468 => 0,
}

class Meiro::Tile::BaseTile
  attr_accessor :object, :character, :searched

  def any?
    !!(@object || @character)
  end

  def empty?
    !(@object || @character)
  end

  def any_one?
    !!@character
  end

  def no_one?
    !@character
  end

  def no_object?
    !@object
  end

  def clear
    clear_object
    clear_character
  end

  def clear_object
    @object = nil
  end

  def clear_character
    @character = nil
  end

  def width
    self.respond_to?(:image) ? self.image.width : 0
  end

  def height
    self.respond_to?(:image) ? self.image.height : 0
  end

  # 探索済みの床か否か
  # マップ表示に利用
  def searched?
    !!@searched
  end

end

class Meiro::Tile::Flat
  def image
    IMAGES[27]
  end
end

class Meiro::Tile::Wall
  def image
    if matched = self.class.to_s.match(/Meiro::Tile::Chipped(\d+)/)
      IMAGES[TILE_IMAGE_KEY_MAP[matched[1].to_i]] || IMAGES[4]
    else
      IMAGES[4]
    end
  end
end

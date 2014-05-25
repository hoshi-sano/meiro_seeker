module MyDungeonGame
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # 共通定数の定義
  WIDTH_TILE_NUM = 100
  HEIGHT_TILE_NUM = 50
  DEFAULT_MIN_ROOM_NUM = 1
  DEFAULT_MAX_ROOM_NUM = 6
  DEFAULT_MIN_ROOM_WIDTH = 8
  DEFAULT_MIN_ROOM_HEIGHT = 6
  DEFAULT_MAX_ROOM_WIDTH = 20
  DEFAULT_MAX_ROOM_HEIGHT = 20
  BLOCK_SPLIT_FACTOR = 3.0
  TILE_WIDTH = 48
  TILE_HEIGHT = 48
  DISPLAY_WIDTH = 640
  DISPLAY_HEIGHT = 480
  RESPAWN_INTERVAL = 50
  RADAR_MAP_UNIT_SIZE = 5

  RADAR_MAP_COLOR = {
    player: [255, 255, 0],
    mob:    [255, 0, 0],
    item:   [0, 200, 255],
    stairs: [0, 170, 220],
    tile:   [0, 0, 255],
  }

  RADAR_MAP_ALPHA = {
    player: 255,
    mob:    255,
    item:   255,
    stairs: 255,
    tile:   80,
  }

  TRANSPARENT = {
    color: [255, 255, 255],
    alpha: 0,
  }

  WINDOW_SIZE = {
    menu:      [200, 75],
    item:      [300, 300],
    item_menu: [120, 130],
    yes_no:    [150, 80],
    message:   [600, 100],
    parameter: [600, 40],
  }
  WINDOW_COLOR = {
    regular: [0, 30, 30],
  }
  WINDOW_ALPHA = {
    regular: 200,
  }
  WINDOW_POSITION = {
    menu: [30, 50],
    item: [240, 50],
    item_menu: [110, 150],
  }

  HP_METER_HEIGHT = 5
  HP_METER_COLOR = {
    current: [0, 255, 0],
    max:     [255, 0, 0],
  }
  HP_METER_ALPHA = {
    current: 255,
    max:     255,
  }
  STOMACH_METER_HEIGHT = 3
  STOMACH_METER_COLOR = {
    current: [0, 150, 200],
    max:     [0,  80, 130],
  }
  STOMACH_METER_ALPHA = {
    current: 255,
    max:     255,
  }

  MESSAGE_SPEED = 4

  MOVE_UNIT = 8
  CHARACTER_PATTERN_NUM_X = 4
  CHARACTER_PATTERN_NUM_Y = 8
  CHARACTER_WALK_PATTERN = 0..3
  CHARACTER_DEATH_ANIMATION_LENGTH = 10
  CHARACTER_DAMAGE_ANIMATION_LENGTH = 4
  CHARACTER_DIRECTION = {
    :S => 0,  # 上
    :W => 1,  # 下
    :E => 2,  # 左
    :N => 3,  # 右
    :SW => 4, # 左上
    :SE => 5, # 右上
    :NW => 6, # 左下
    :NE => 7, # 右下
  }
  CHARACTER_INPUT_DIRECTION_MAP = {
    [ 0, -1] => :N,
    [ 0,  1] => :S,
    [-1,  0] => :W,
    [ 1,  0] => :E,
    [-1,  1] => :SW,
    [ 1,  1] => :SE,
    [-1, -1] => :NW,
    [ 1, -1] => :NE,
  }

  PORTABLE_ITEM_NUMBER = 20
  PLAYER_ATTACK_ACCURACY = 95
  MOB_ATTACK_ACCURACY = 85
  THROW_ACCURACY = 85

  PLAYER_IMAGE_PATH = File.join(ROOT, 'data', 'uno.png')
  ENEMY_IMAGE_PATH  = File.join(ROOT, 'data', 'uno2.png')
  STAIRS_IMAGE_PATH = File.join(ROOT, 'data', 'stairs.png')
  POTION_IMAGE_PATH = File.join(ROOT, 'data', 'potion.png')
  MANJU_IMAGE_PATH = File.join(ROOT, 'data', 'manju.png')
  WORD_LIST_PATH    = File.join(ROOT, 'data', 'words.yml')
  MESSAGE_LIST_PATH = File.join(ROOT, 'data', 'messages.yml')
end

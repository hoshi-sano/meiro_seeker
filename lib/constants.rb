module MyDungeonGame
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # 共通定数の定義
  # TODO: 調整
  WIDTH_TILE_NUM = 70
  HEIGHT_TILE_NUM = 60
  DEFAULT_MIN_ROOM_NUM = 4
  DEFAULT_MAX_ROOM_NUM = 16
  DEFAULT_MIN_ROOM_WIDTH = 3
  DEFAULT_MIN_ROOM_HEIGHT = 3
  DEFAULT_MAX_ROOM_WIDTH = 10
  DEFAULT_MAX_ROOM_HEIGHT = 10
  BLOCK_SPLIT_FACTOR = 30.0
  TILE_WIDTH = 48
  TILE_HEIGHT = 48
  DISPLAY_WIDTH = 640
  DISPLAY_HEIGHT = 480
  DISPLAY_RANGE_X = 8
  DISPLAY_RANGE_Y = 6
  RESPAWN_INTERVAL = 50
  RADAR_MAP_UNIT_SIZE = 5
  THROW_RANGE = 10
  THROW_ALTITUDE = 10
  MINIMUM_DAMAGES = [0, 1]

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
    title_menu: [190, 65],
    game_data:  [400, 200],
    menu:      [200, 75],
    sub_menu:  [120, 100],
    item:      [300, 300],
    item_menu: [120, 130],
    item_note: [500, 200],
    yes_no:    [150, 80],
    message:   [600, 100],
    parameter: [600, 40],
    key_config: [380, 300],
    underfoot_item: [300, 40],
  }
  WINDOW_COLOR = {
    regular: [0, 30, 30],
  }
  WINDOW_ALPHA = {
    regular: 200,
    item_note: 255,
  }
  WINDOW_POSITION = {
    title_menu: [30, 30],
    menu: [30, 50],
    item: [240, 50],
    sub_menu: [110, 130],
    item_menu: [110, 150],
    item_note: [60, 100],
    key_config: [240, 50],
  }
  MAP_NAME_POSITION = [30, 200]

  HP_METER_HEIGHT = 5
  HP_METER_COLOR = {
    current: [0, 255, 0],
    max:     [255, 0, 0],
    zero:    [0, 0, 0],
  }
  HP_METER_ALPHA = {
    current: 255,
    max:     255,
    zero:    0,
  }
  STOMACH_METER_HEIGHT = 3
  STOMACH_METER_COLOR = {
    current: [0, 150, 200],
    max:     [0,  80, 130],
    zero:    [0, 0, 0],
  }
  STOMACH_METER_ALPHA = {
    current: 255,
    max:     255,
    zero:    0,
  }

  STARTING_BREAK_TIME = 85
  MESSAGE_SPEED = 4

  MOVE_UNIT = 8
  CHARACTER_PATTERN_NUM_X = 8
  CHARACTER_PATTERN_NUM_Y = 8
  CHARACTER_WALK_PATTERN = 0..3
  CHARACTER_ATTACK_PATTERN = 4..7
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
  CHARACTER_ATTACK_MOVE_AND_FRAMES = [
                                      [0,  0], [0,  0],
                                      [5,  1], [10, 1],
                                      [15, 2], [12, 2],
                                      [9,  3], [6,  3], [3, 3],
                                     ]
  AROUND_CELL_DXDY = [
    [1, 0], [-1, 0], [0, -1], [1, -1], [-1, -1], [0, 1], [1, 1], [-1, 1],
  ]

  PORTABLE_ITEM_NUMBER = 20
  PLAYER_ATTACK_ACCURACY = 95
  MOB_ATTACK_ACCURACY = 85
  THROW_ACCURACY = 85
  MAX_CALIBRATION = 99

  ENEMY_GROUPS = [
    :normal, # ノーマル系
    :ghost,  # ゴースト系
    :dragon, # ドラゴン系
  ]
  # 状態異常・特殊技能
  STATUS_NAMES = {
    escape:         '逃亡',
    confusion:      '混乱',
    anti_confusion: '混乱よけ',
    second_sight:   '透視',
    hungry:         'ハラヘリ',
    anti_hungry:    'ハラヘラズ',
    ghost_buster:   'ゴーストバスター',
    dragon_buster:  'ドラゴンバスター',
    anti_steal:     '泥棒よけ',
  }
  STATUSES = STATUS_NAMES.keys

  SAVE_FILE_PATH     = File.join(ROOT, 'data', 'save.dat')
  OLD_SAVE_FILE_PATH = File.join(ROOT, 'data', 'save.dat.old')

  TITLE_BG_IMAGE_PATH = File.join(ROOT, 'data', 'title.png')
  PLAYER_IMAGE_PATH = File.join(ROOT, 'data', 'uno.png')
  ENEMY_IMAGE_PATH  = File.join(ROOT, 'data', 'uno2.png')
  STAIRS_IMAGE_PATH = File.join(ROOT, 'data', 'stairs.png')
  WEAPON_IMAGE_PATH = File.join(ROOT, 'data', 'weapon.png')
  SHIELD_IMAGE_PATH = File.join(ROOT, 'data', 'shield.png')
  BULLET_IMAGE_PATH = File.join(ROOT, 'data', 'shuriken.png')
  POTION_IMAGE_PATH = File.join(ROOT, 'data', 'potion.png')
  MANJU_IMAGE_PATH  = File.join(ROOT, 'data', 'manju.png')
  GRIMOIRE_IMAGE_PATH = File.join(ROOT, 'data', 'grimoire.png')
  WORD_LIST_PATH    = File.join(ROOT, 'data', 'words.yml')
  MESSAGE_LIST_PATH = File.join(ROOT, 'data', 'messages.yml')
  DICTIONARY_PATH   = File.join(ROOT, 'data', 'dictionary.yml')
  SCENES_PATH       = File.join(ROOT, 'data', 'scenes.yml')
  MAP_DATA_PATH     = File.join(ROOT, 'data', 'map_data.yml')
  FONT_BASE_DIR     = File.join(ROOT, 'data', 'fonts')
  FONT_PATHES       = [
    File.join('PixelMplus', 'PixelMplus12-Regular.ttf'),
  ].map { |path| File.join(FONT_BASE_DIR, path) }
end

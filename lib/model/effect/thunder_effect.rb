module MyDungeonGame
  # 落雷エフェクト
  class ThunderEffect < Effect
    pattern_x       8
    pattern_y       1
    update_interval 1
    image_path      File.join(ROOT, 'data', 'thunder-effect.png')

    class << self
      def surround_player_xy_small(player)
        [[ player.x      * TILE_WIDTH, (player.y - 8)  * TILE_HEIGHT],
         [(player.x - 1) * TILE_WIDTH, (player.y - 9)  * TILE_HEIGHT],
         [(player.x + 1) * TILE_WIDTH, (player.y - 9)  * TILE_HEIGHT],
         [ player.x      * TILE_WIDTH, (player.y - 10) * TILE_HEIGHT]]
      end

      def surround_player_xy_big(player)
        [[ player.x      * TILE_WIDTH, (player.y - 7)  * TILE_HEIGHT],
         [(player.x - 2) * TILE_WIDTH, (player.y - 8)  * TILE_HEIGHT],
         [(player.x + 2) * TILE_WIDTH, (player.y - 8)  * TILE_HEIGHT],
         [(player.x - 3) * TILE_WIDTH, (player.y - 9)  * TILE_HEIGHT],
         [(player.x + 3) * TILE_WIDTH, (player.y - 9)  * TILE_HEIGHT],
         [(player.x - 2) * TILE_WIDTH, (player.y - 10) * TILE_HEIGHT],
         [(player.x + 2) * TILE_WIDTH, (player.y - 10) * TILE_HEIGHT],
         [ player.x      * TILE_WIDTH, (player.y - 11) * TILE_HEIGHT]]
      end
    end
  end
end

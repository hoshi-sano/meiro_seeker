module MyDungeonGame
  # 敵キャラクターのベースとなるクラス
  class EnemyCharacter < FollowPlayerCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    hate true
    name "ENEMY"
    level 1
    hp 10
    power 2

    def attackable?(target)
      self.hate? != !!target.hate?
    end

    def go_toward(xy)
      candidates = {}
      ((self.y - 1)..(self.y + 1)).each do |cand_y|
        ((self.x - 1)..(self.x + 1)).each do |cand_x|
          # MEMO: 移動候補先に味方キャラクターがいたら移動不可
          #       移動候補先に敵キャラクターがいたら移動可能(攻撃)
          if throughable?(cand_x - self.x, cand_y - self.y)
            tile = @floor[cand_x, cand_y]
            next if (tile.any_one? && !attackable?(tile.character))
            dist = calc_distance(cand_x, cand_y, *xy)
            candidates[dist] ||= []
            candidates[dist] << [cand_x, cand_y]
          end
        end
      end

      key = candidates.keys.min
      return [0, 0] if key.nil? # 候補が何もない場合
      cand_x, cand_y = candidates[key].first
      [cand_x - self.x, cand_y - self.y]
    end
  end
end

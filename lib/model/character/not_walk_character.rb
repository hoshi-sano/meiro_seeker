module MyDungeonGame
  # 自動で移動しないモブキャラクター
  class NotWalkCharacter < MobCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH

    def _action
      if has_status?(:confusion)
        random_walk
      else
        walk_to(0, 0)
      end
    end
  end
end

module MeiroSeeker
  # 自動で移動しない、場所交換もできないモブキャラクター
  class ImmovableCharacter < NotWalkCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH

    def movable?(dx, dy)
      false
    end

    def throughable?(dx, dy)
      false
    end
  end
end

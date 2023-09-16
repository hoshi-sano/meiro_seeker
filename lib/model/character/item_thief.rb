module MeiroSeeker
  # アイテムを盗むモンスター
  class ItemThief < EnemyCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    hate true
    name "泥棒猫"
    level   1
    hp      1
    power   2
    defence 1
    exp     4
    speed   1
    skill WaitAndSee,     rate: 15
    skill ItemStealSkill, rate: 85, after_state: :escape
  end
end

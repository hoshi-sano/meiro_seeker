module MyDungeonGame
  # プレイヤーを感知している場合、優先してプレイヤーを追いかける行動を
  # とるキャラクターのベースとなるクラス
  class FollowPlayerCharacter < IntelligentCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH

    def action
      super

      # 行動後プレイヤーを感知している場合、アタリをつけておく
      # 次の行動でプレイヤーを感知していない場合に利用する
      @reserve_xy ||= sensing_player_xy
    end

    # プレイヤーを感知している場合、その座標を返す
    def sensing_player_xy
      if room = @floor.get_room(self.x, self.y)
        room.player_xy
      else
        neighboring_player_xy
      end
    end

    private

    # プレイヤーが隣接している場合、その座標を返す
    def neighboring_player_xy
      res = nil
      ((self.y - 1)..(self.y + 1)).each do |cand_y|
        ((self.x - 1)..(self.x + 1)).each do |cand_x|
          target = @floor[cand_x, cand_y]
          if target.any_one? && target.character.type == :player
            res = [cand_x, cand_y]
            break
          end
        end
      end
      res
    end

    # 自身が部屋内にいる場合の移動先決定
    def analyse_in_room
      @reserve_xy = nil
      dx, dy = nil, nil
      if player_xy = @room.player_xy
        # 同じ部屋にプレイヤーがいる場合
        @distance = calc_distance(self.x, self.y, *player_xy)
        dx, dy = go_toward(player_xy)
      else
        # 自身は部屋にいるがプレイヤーが同じ部屋にいない場合
        @distance = -1
        if gate = decide_dest_gate_xy(@room.gate_coordinates)
          dx, dy = go_toward(gate)
          @dest_gate = nil if [self.x + dx, self.y + dy] == @dest_gate
        end
      end
      [dx, dy]
    end

    # 自身が部屋外にいる場合の移動先決定
    def analyse_outside_room
      @dest_gate = nil
      dx, dy = nil, nil
      if player_xy = neighboring_player_xy
        # プレイヤーが隣接している場合
        @reserve_xy = nil
        dx, dy = go_toward(player_xy)
      elsif @reserve_xy
        # 直前にプレイヤーを感知していた場合
        dx, dy = go_toward(@reserve_xy)
        @reserve_xy = nil if [self.x + dx, self.y + dy] == @reserve_xy
      else
        # プレイヤーを見失っている場合
        @reserve_xy = nil
        dx, dy = go_ahead
      end
      [dx, dy]
    end

    # 自身が部屋にいて、部屋内に目標物がない場合、いずれかの出入口に向
    # かう。この時に、どの出入口に向かうかを決めるためのメソッド。
    def decide_dest_gate_xy(candidates)
      # 出入口にプレイヤーがいる場合はそこを優先
      candidates.each do |cand_x, cand_y|
        if @floor[cand_x, cand_y].any_one? &&
            @floor[cand_x, cand_y].character.type == :player
          @dest_gate = [cand_x, cand_y]
        end
      end
      super
    end
  end
end

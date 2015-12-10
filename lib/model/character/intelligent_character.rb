module MyDungeonGame
  # 現状を分析し、通路を通る、突き当りで右左折する、引き返すなど知的な
  # 行動ができるキャラクターのベースとなるクラス
  class IntelligentCharacter < MobCharacter
    type :mob
    update_interval 10
    image_path ENEMY_IMAGE_PATH
    name "MOB"
    speed 0.5

    def _action
      return if @hp <= 0
      # 現状把握
      dx, dy = analyse
      if dx && dy
        change_direction_by_dxdy(dx, dy)
        # 移動先に誰かいたら攻撃、誰もいなければ移動成立
        if @floor[self.x + dx, self.y + dy].any_one?
          target = @floor[self.x + dx, self.y + dy].character
          attack_to(target) if attackable?(target)
        else
          walk_to(dx, dy)
        end
      else
        # dx, dy が得られないパターンは以下
        # * 出入口のない部屋にいて且つプレイヤーがいない
        random_walk
      end
    end

    # 攻撃可能かどうかの判定
    def attackable?(target)
      false
    end

    # 自身が今の場所に移動する直前に
    # 引数で渡す座標にいたかどうかを返す
    def prev?(x, y)
      if self.prev_x && self.prev_y
        self.prev_x == x && self.prev_y == y
      else
        false
      end
    end

    private

    # 状況に応じた移動先の決定
    def analyse
      dx, dy = nil, nil
      @room = @floor.get_room(self.x, self.y)
      if @room
        dx, dy = analyse_in_room
      else
        dx, dy = analyse_outside_room
      end

      [dx, dy]
    end

    # 自身が部屋内にいる場合の移動先決定
    def analyse_in_room
      if gate = decide_dest_gate_xy(@room.gate_coordinates)
        dx, dy = go_toward(gate)
        @dest_gate = nil if [self.x + dx, self.y + dy] == @dest_gate
      end
      [dx, dy]
    end

    # 自身が部屋外にいる場合の移動先決定
    def analyse_outside_room
      go_ahead
    end

    # 自身が部屋にいて、部屋内に目標物がない場合、いずれかの出入口に向
    # かう。この時に、どの出入口に向かうかを決めるためのメソッド。
    def decide_dest_gate_xy(candidates)
      res = nil
      return res if candidates.empty?

      # 既に決めた出入口がある場合はそこを優先
      if @dest_gate
        res = @dest_gate
      else
        # 上のいずれにも当てはまらない場合は、自身が入ってきた出入口以
        # 外の出入口を選択する。出入口がひとつしかない場合は自身が入っ
        # てきた出入口に戻る。
        if candidates.size == 1
          @dest_gate = candidates.first
        else
          while @dest_gate.nil?
            # 全体が一様な動きをするのを防ぐためランダムに選択
            cand_x, cand_y = random_select(candidates)
            @dest_gate = [cand_x, cand_y] if !prev?(cand_x, cand_y)
            res = @dest_gate
          end
        end
      end
      res
    end

    # 直進する。直進できない場合は方向転換する。
    # 優先度は1.直進、2.左折、3.右折、4.後退の順。
    # いずれも不可能な場合は移動しない。
    def go_ahead
      candidates = DIRECTION_STEP_MAP[@current_direction]
      res = nil
      candidates.values.each do |cand_x, cand_y|
        dest = @floor[self.x + cand_x, self.y + cand_y]
        if dest.walkable? && dest.no_one?
          res = [cand_x, cand_y]
          break
        end
      end
      res || [0, 0]
    end

    # 引数に指定した座標を目標に移動する。
    # 移動先の座標候補に、目標物との距離による重み付けをして、もっとも
    # 最短距離となる移動先を選択する。座標候補がない場合は移動しない。
    def go_toward(xy)
      candidates = {}
      ((self.y - 1)..(self.y + 1)).each do |cand_y|
        ((self.x - 1)..(self.x + 1)).each do |cand_x|
          # MEMO: 移動先にキャラクターがいる場合は移動不可
          if movable?(cand_x - self.x, cand_y - self.y)
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

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
      # 現状把握
      dx, dy = analyse

      # 可能であれば確率でスキル発動
      return if !has_status?(:confusion) && do_skill

      # スキルを発動しない場合は移動または通常攻撃
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

    def do_skill
      # keyがSkill、valueがRangeのハッシュを作る
      # 例: { Skill1 => 0...30, Skill2 => 31...50 }
      usable_skills = skill_to_rates.keys.select { |s| s.usable?(self) }
      rate_counter = 0
      usable_skill_to_rate = Hash[
        usable_skills.map { |skill|
          res = [skill, (rate_counter...(rate_counter + skill_to_rates[skill]))]
          rate_counter += skill_to_rates[skill]
          res
        }
      ]
      return if usable_skills.empty?

      # 確率でスキルの発動を判定
      invoke_skill = nil
      c = randomizer.rand(100)
      usable_skill_to_rate.each do |skill, rate|
        if rate.include?(c)
          invoke_skill = skill
          break
        end
      end
      invoke_skill.invoke(self) if invoke_skill
      !!invoke_skill
    end

    # 攻撃可能かどうかの判定
    def attackable?(target)
      # ワープ済の相手は攻撃不可
      return false if target.warped || @warped

      # 自身は攻撃不可、通過不可能な位置の相手は攻撃不可
      if (target == self) || !throughable?(target.x - self.x, target.y - self.y)
        return false
      end
      # 基本的にすべてのtargetに対して攻撃しない
      # 混乱時のみ、誰でも攻撃する
      has_status?(:confusion)
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

    # プレイヤーと隣接しているか否かを返す
    def adjoin_player?
      !!neighboring_player_xy
    end

    # プレイヤーが隣接している場合、その座標を返す
    def neighboring_player_xy
      res = nil
      player = GeneralManager.current_scene.player
      if (self.x - player.x).abs <= 1 && (self.y - player.y).abs <= 1
        res = [player.x, player.y]
      end
      res
    end

    # プレイヤーが隣接している場合、プレイヤーを返す
    def neighboring_player
      neighboring_player_xy ? GeneralManager.current_scene.player : nil
    end

    # 直線上にプレイヤーがいるか否かを返す
    def alignment_with_player?
      !!straight_player_xy
    end

    # 直線上にプレイヤーがいる場合、その座標を返す
    def straight_player_xy
      res = nil
      player = GeneralManager.current_scene.player
      if self.x == player.x ||
         self.y == player.y ||
         (self.x - player.x).abs == (self.y - player.y).abs
        res = [player.x, player.y]
      end
      res
    end

    private

    # 状況に応じた移動先の決定
    def analyse
      # 混乱時はランダム移動
      return random_walk_dxdy if has_status?(:confusion)

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
    # invertフラグが立っている場合は目標物から離れるようにして移動する。
    # 返り値は [dx, dy] で返す。
    def go_toward(xy, invert=nil)
      # 明確にinvertフラグが指定されておらず、逃亡中の状態で、
      # プレイヤーを感知している場合はinvertフラグを立てる
      if invert.nil? && has_status?(:escape) && sensing_player_xy
        invert = true
      end
      candidates = {}
      ((self.y - 1)..(self.y + 1)).each do |cand_y|
        ((self.x - 1)..(self.x + 1)).each do |cand_x|
          # MEMO: 移動候補先に味方キャラクターがいたら移動不可
          #       移動候補先に攻撃対象がいたら移動可能(攻撃)
          if throughable?(cand_x - self.x, cand_y - self.y)
            tile = @floor[cand_x, cand_y]
            next if (tile.any_one? && !attackable?(tile.character))
            dist = calc_distance(cand_x, cand_y, *xy)
            candidates[dist] ||= []
            candidates[dist] << [cand_x, cand_y]
          end
        end
      end

      choice = invert ? :max : :min
      key = candidates.keys.send(choice)
      return [0, 0] if key.nil? # 候補が何もない場合
      # 候補がある場合は前方方向を優先
      cand_x, cand_y = nil, nil
      dirs = DIRECTION_STEP_MAP[@current_direction]
      dirs.values_at(:forward, :f_left, :right).each do |dx, dy|
        xy = [self.x + dx, self.y + dy]
        if candidates[key].include?(xy)
          cand_x, cand_y = *xy
          break
        end
      end
      # TODO: 逃亡中は壁沿いを再優先したい
      # 正面系の候補がなかった場合は一番最初のものをチョイス
      cand_x, cand_y = candidates[key].first if cand_x.nil?
      [cand_x - self.x, cand_y - self.y]
    end
  end
end

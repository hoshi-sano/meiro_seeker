module MyDungeonGame
  # 武器の基本となるクラス
  class Weapon < Equipment
    TYPE = :weapon

    def order
      if self.equipped?
        ORDER[:equipped_weapon]
      else
        ORDER[:weapon]
      end
    end

    # 基本性能
    # 見た目上の強さで、あくまで目安
    def strength
      @base_strength + @calibration
    end

    # 実際にダメージ計算などに使われる値
    def offence
      if @calibration_cache == @calibration
        @strength_cache
      else
        @calibration_cache = @calibration
        c = @calibration
        base = @base_strength
        inclination = ((Math.log(base + 1) / Math.log(1.6)) ** 2) / 50
        intercept   = (Math.log((base / 5) + 1) / Math.log(1.6)) ** 2
        if c >= 0
          @strength_cache = c * inclination + intercept
        else
          @strength_cache = intercept * (base * c) / base
        end
        @strength_cache
      end
    end

    def hit_event(scene, thrower, target)
      e = super
      damage = ((self.offence / 2) +
                thrower.calc_level_calibration +
                thrower.calc_power_calibration).round
      # TODO: targetの防御力を加味する
      target.hp -= damage
      e.set_next(DamageEvent.create(scene, target, damage))
      msg = MessageManager.to_damage(damage)
      e.set_next(ShowMessageEvent.create(scene, msg))

      # アイテムヒットによって対象のHPが0になった場合
      scene.instance_eval do
        if target.dead?
          thrower.kill(target)
          @floor.remove_character(target.x, target.y)
        end

        judge = Event.new do |e|
          # killメソッドによってthrowerの@eventsにpackしたイベントが登
          # 録されるため、それを直ちに実行すべく展開してcut_inする
          while event_packet = thrower.pop_event
            e.set_next_cut_in(event_packet.unpack(self))
          end
          e.finalize
        end
        e.set_next(judge)
      end

      e
    end
  end
end

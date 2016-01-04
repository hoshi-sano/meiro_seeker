module MyDungeonGame
  # HP回復系アイテムの共通処理
  class HpRecoverItem < Potion
    class << self
      def recover_point(val)
        @recover_point = val
      end

      def gain(val)
        @gain = val
      end
    end

    def recover_point
      self.class.instance_variable_get(:@recover_point) || 0
    end

    def gain
      self.class.instance_variable_get(:@gain) || 0
    end

    def effect_event(scene)
      ParamRecoverEvent.create(scene, scene.player, :hp, recover_point, gain)
    end

    def hit_event(scene, thrower, target)
      return Event.new { |e| e.finalize } if thrower.dead?
      with_death_check(scene, thrower, target) do |scene, thrower, target|
        e = super
        if target.type == :player
          # プレイヤーの場合はHPがrecover_point分だけ回復
          # HPが満タンだった場合はHPの最大値がgain分だけ上昇
          r = ParamRecoverEvent.create(scene, target, :hp, recover_point, gain)
          e.set_next(r)
        elsif target.included?(:ghost)
          # ゴースト系の場合はダメージ
          target.hp -= recover_point
          e.set_next(DamageEvent.create(scene, target, recover_point))
          msg = MessageManager.to_damage(recover_point)
          e.set_next(ShowMessageEvent.create(scene, msg))
        else
          # モブの場合はHPがrecover_point分だけ回復、HP最大値上昇はなし
          e.set_next(ParamRecoverEvent.create(scene, target, :hp, recover_point))
        end
        e
      end
    end
  end
end

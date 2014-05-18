module MyDungeonGame
  # 被ダメージ演出
  module DamageEvent
    module_function

    def create(scene, target, damage)
      scene.instance_eval do
        # TODO: 最終的には点滅はいらない。画像が変わるだけでいい。
        if target.type == :player
          res = Event.new do |e|
            # プレーヤーへのダメージの場合、画面に表示する残りHPと被ダ
            # メージ演出をシンクロさせるため、ここでHPの計算を行う
            target.hp -= damage
            target.hp = 0 if target.hp < 0
            target.show_switch
            e.finalize
          end
        else
          res = Event.new {|e| target.show_switch; e.finalize }
        end
        anime_length = CHARACTER_DAMAGE_ANIMATION_LENGTH
        anime_length.times do |i|
          if i < anime_length - 1
            ev = i.even? ? Event.new {|e| target.show_switch; e.finalize } :
              Event.new {|e| e.finalize }
          else
            ev = Event.new {|e| target.show; e.finalize }
          end
          res.set_next(ev)
        end
        res
      end
    end
  end
end

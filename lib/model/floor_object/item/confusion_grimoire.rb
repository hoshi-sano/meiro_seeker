module MyDungeonGame
  # 混迷の魔導書
  # 部屋全体のモンスターを20ターン混乱状態にする
  class ConfusionGrimoire < Grimoire
    range_type :room
    name       MessageManager.get('dict.items.confusion_grimoire.name')
    note       MessageManager.get('dict.items.confusion_grimoire.note')

    def effect_event(scene)
      # TODO: エフェクト
      Event.new do |e|
        target_characters(scene).each do |t|
          t.temporary_status_set(:confusion, 20)
        end
        e.finalize
      end
    end
  end
end

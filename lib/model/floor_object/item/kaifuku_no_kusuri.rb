module MyDungeonGame
  # 回復の薬
  class KaifukuNoKusuri < HpRecoverItem
    type :item
    name MessageManager.get('dict.items.kaifuku_no_kusuri.name')
    note MessageManager.get('dict.items.kaifuku_no_kusuri.note')
    image IMAGES[:potion]
    recover_point 100
    gain          2
  end
end

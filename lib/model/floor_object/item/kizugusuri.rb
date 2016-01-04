module MyDungeonGame
  # 傷薬
  class Kizugusuri < HpRecoverItem
    name          MessageManager.get('dict.items.kizugusuri.name')
    note          MessageManager.get('dict.items.kizugusuri.note')
    recover_point 25
    gain          1
  end
end

module MeiroSeeker
  # 肉まん
  # 満腹度回復系
  class NikuMan < Manju
    name MessageManager.get('dict.items.niku_man.name')
    note MessageManager.get('dict.items.niku_man.note')
    recover_point 100
    gain          5
  end
end

module MeiroSeeker
  # マントウ
  # 満腹度回復系
  class Mantou < Manju
    name MessageManager.get('dict.items.mantou.name')
    note MessageManager.get('dict.items.mantou.note')
    recover_point 50
    gain          3
  end
end

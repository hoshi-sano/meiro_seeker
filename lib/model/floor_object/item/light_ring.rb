module MyDungeonGame
  # 透視能力を付与する指輪
  class LightRing < Ring
    name         MessageManager.get('dict.items.light_ring.name')
    note         MessageManager.get('dict.items.light_ring.note')
    extra_effect :second_sight
  end
end

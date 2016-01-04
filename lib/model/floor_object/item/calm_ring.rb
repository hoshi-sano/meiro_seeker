module MyDungeonGame
  # 混乱を防ぐ指輪
  class CalmRing < Ring
    name         MessageManager.get('dict.items.calm_ring.name')
    note         MessageManager.get('dict.items.calm_ring.note')
    extra_effect :anti_confusion
  end
end

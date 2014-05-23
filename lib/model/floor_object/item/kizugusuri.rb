module MyDungeonGame
  class Kizugusuri < Item
    name MessageManager.get('item_names.kizugusuri')

    def event
      e = nil
      # 全ウインドウの消去
      e = ClearMenuWindowEvent.create(@scene)
      # 使用した旨のメッセージの表示
      msg = MessageManager.player_use_item(@scene.player.name, @name)
      e.set_next(ShowMessageEvent.create(@scene, msg))

      # TODO: アイテム使用演出
      # HP回復の実行
      # TODO: 数値のパラメータ化
      e.set_next(HpRecoverEvent.create(@scene, @scene.player, 25, 2))
      e
    end
  end
end

module MyDungeonGame
  # タイトルのシーン
  class TitleScene
    # NOTE: 引数は不要かも(ダックタイピイング的に必要かも)
    def initialize(_=nil, _=nil, _=nil)
      @menu_windows = []

      game_data = GeneralManager.load
      @data_window = GameDataWindow.new(game_data) if game_data

      @choices = {
        # セーブデータからゲームを開始する場合
        MessageManager.get(:resume) => lambda {
          if game_data
            @data_window.show
            letter = { question: MessageManager.get(:confirm_resume_game) }
            events = {
              yes: lambda { |e|
                refresh
                GeneralManager.set_game_data(game_data)
              },
              no: lambda { |e| refresh; e.finalize },
            }
            YesNoEvent.create(self, letter, events)
          else
            # セーブデータが存在しない旨を表示する処理
            msg = MessageManager.get(:no_saved_data)
            e = ShowMessageEvent.create(self, msg, force_wait_input: true)
            e.set_finalize_action(-1) { refresh }
            e
          end
        },
        # 最初からゲームを開始する場合
        MessageManager.get(:new_game) => lambda {
          if game_data
            @data_window.show
            letter = {
              question: MessageManager.get(:confirm_new_game),
              # 押し間違いを防ぐため、yesの位置を「いいえ」とする
              yes: MessageManager.get(:no),
              no:  MessageManager.get(:yes),
            }
            events = {
              # 押し間違い防止でyesだけど内容的には「いいえ」の処理
              yes: lambda { |e| refresh; e.finalize },
              # 押し間違い防止でnoだけど内容的には「いいえ」の処理
              no: lambda { |e| refresh; GeneralManager.create_new_game_data },
            }
            YesNoEvent.create(self, letter, events)
          else
            GeneralManager.create_new_game_data
          end
        },
      }
      @em = EventManager.new(ShowStartMenuEvent.create(self))
    end

    # 基本のループ処理
    def update
      @em.do_event
      display_window
      OutputManager.update
    end

    def refresh
      @data_window.hide if @data_window
      @menu_windows = []
    end

    def display_window
      display_message_window
      display_yes_no_window
      display_menu_window
      display_game_data_window
    end

    def display_game_data_window
      OutputManager.reserve_draw_game_data_window(@data_window) if @data_window
    end

    # MEMO: 他のシーンと共通化出来る
    def display_message_window
      if @message_window
        OutputManager.reserve_draw_message_window(@message_window)
        # TTLが枯渇するまで一定時間表示する
        if @message_window.alive?
          @message_window.tick
        else
          @message_window = nil
        end
      end
    end

    # MEMO: 他のシーンと共通化出来る
    def display_menu_window
      @menu_windows.each do |window|
        OutputManager.reserve_draw_menu_window(window)
      end
    end

    # MEMO: 他のシーンと共通化出来る
    def display_yes_no_window
      if @yes_no_window
        OutputManager.reserve_draw_yes_no_window(@yes_no_window)
      end
    end
  end
end

module MeiroSeeker
  # 「はい/いいえ」のような２択の質問を発生させるイベント
  module YesNoEvent
    module_function

    EMPTY_EVENTS = {
      yes: lambda {|e| e.finalize },
      no:  lambda {|e| e.finalize },
    }

    # letter: 質問と２択の文言を指定する
    #         (例) {question:"りんごは好き？", yes:"好き", no:"嫌い"}
    #
    # events: ２択の選択時に発生するイベントをそれぞれ指定する。指定し
    #         なかった場合は何もしないイベント(EMPTY_EVENTS)が適用される。
    def create(scene, letter, events, font_type=:regular)
      question = letter[:question]
      yes = letter[:yes]
      no  = letter[:no]
      events = EMPTY_EVENTS.merge(events)

      scene.instance_eval do
        yes_or_no = Event.new do |e|
          if question
            @message_window ||= MessageWindow.new('')
            @message_window.clear
            @message_window.message = question
            @message_window.permanence!
          else
            @message_window.set_ttl(0) if @message_window
          end
          @yes_no_window = YesNoWindow.new(yes, no, font_type)
          e.finalize
        end

        wait_input = Event.new do |e|
          dy = InputManager.get_y
          # 上下が押されたら「はい/いいえ」を指す矢印の位置を変更
          @yes_no_window.switch(dy) if !(dy.zero?)

          if InputManager.down_ok?
            if @yes_no_window.yes?
              e.set_next_cut_in(Event.new(&events[:yes]))
            else
              e.set_next_cut_in(Event.new(&events[:no]))
            end
            @message_window.set_ttl(0) if @message_window
            @yes_no_window = nil
            e.finalize
          end
        end
        yes_or_no.set_next(wait_input)

        yes_or_no
      end
    end
  end
end

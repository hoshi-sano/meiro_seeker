module MeiroSeeker
  class GameDataWindow < BaseWindow
    # TODO: クラス内でポジションを設定できるようにする
    # position WINDOW_POSITION[:game_data]
    bg_image ViewProxy.rect(*WINDOW_SIZE[:game_data],
                            WINDOW_COLOR[:regular], WINDOW_ALPHA[:regular])

    TRANSPARENCY =
      ViewProxy.rect(1, 1, TRANSPARENT[:color], TRANSPARENT[:alpha])

    attr_reader :text

    def initialize(game_data, font_type=:regular)
      super(font_type)
      @scene = game_data[:current_scene]
      hide
    end

    def generate_text
      # TODO: 最深到達度等の取得と表示
      player = @scene.player
      map_info = @scene.map_info || {}
      storey = @scene.floor.storey
      map_name = map_info[:name]
      map_name = map_info[:name][storey] if map_name.is_a?(Hash)
      reached_floor_num = GeneralManager.reached_floor_num
      "#{player.name} \n\n" \
      "#{storey}F  #{map_name}\n" \
      "Lv#{player.level}  HP #{player.hp}/#{player.max_hp}\n\n" \
      "#{MessageManager.get(:reached_floor)}: #{reached_floor_num}F"
    end

    def hide
      @hide = true
      @text = ''
    end

    def show
      @hide = false
      @text = generate_text
    end

    def image
      if @hide
        TRANSPARENCY
      else
        super
      end
    end
  end
end

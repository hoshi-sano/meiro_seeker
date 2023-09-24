module MeiroSeeker
  # メッセージを管理するクラス
  module MessageManager

    LIST = MESSAGES.merge(WORDS).merge(DICTIONARY)

    PLAYER = 'p'
    LEVEL = 'l'
    ITEM = 'i'
    FROM = 'f'
    TO = 't'
    POINT = 'p'
    ATTACKER = 'a'
    STATUS = 's'

    REGEXP = {
      to:            Regexp.new("#{TO}"),
      item:          Regexp.new("#{ITEM}"),
      point:         Regexp.new("#{POINT}"),
      status:        Regexp.new("#{STATUS}"),
      attacker:      Regexp.new("#{ATTACKER}"),
      item_to:       Regexp.new("[#{ITEM}#{TO}]"),
      to_status:     Regexp.new("[#{TO}#{STATUS}]"),
      from_point:    Regexp.new("[#{FROM}#{POINT}]"),
      player_item:   Regexp.new("[#{PLAYER}#{ITEM}]"),
      player_level:  Regexp.new("[#{PLAYER}#{LEVEL}]"),
      from_to_point: Regexp.new("[#{FROM}#{TO}#{POINT}]"),
    }.freeze

    # define_methodで定義したいものあるため、module_functionを使う代わ
    # りにModuleMethods以下に定義してextendする
    module ModuleMethods

      def get(key)
        if key.kind_of?(Symbol)
          LIST[key]
        else
          keys = key.split('.').map(&:to_sym)
          keys.inject(LIST[keys.shift]){|list, key| list[key] }
        end
      end

      def attack(from, to, damage)
        map = {FROM => from, TO => to, POINT => damage.to_s}
        LIST[:attack].gsub(REGEXP[:from_to_point], map)
      end

      def damage(damage)
        LIST[:damage].gsub(REGEXP[:point], damage.to_s)
      end

      def from_damage(from, damage)
        map = {FROM => from, POINT => damage}
        LIST[:from_damage].gsub(REGEXP[:from_point], map)
      end

      def to_damage(damage)
        LIST[:to_damage].gsub(REGEXP[:point], damage.to_s)
      end

      def kill(target)
        LIST[:kill].gsub(REGEXP[:to], target)
      end

      def confuse(target)
        LIST[:confuse].gsub(REGEXP[:to], target)
      end

      def speed_up(target)
        LIST[:speed_up].gsub(REGEXP[:to], target)
      end

      def missed(attacker)
        LIST[:attacker_missed].gsub(REGEXP[:attacker], attacker)
      end

      def get_exp(point)
        LIST[:get_exp].gsub(REGEXP[:point], point.to_s)
      end

      def level_up(player, level)
        map = {PLAYER => player, LEVEL => level.to_s}
        LIST[:level_up].gsub(REGEXP[:player_level], map)
      end

      def player_use_item(player, item)
        map = {PLAYER => player, ITEM => item}
        LIST[:player_use_item].gsub(REGEXP[:player_item], map)
      end

      def pick_up_item(item)
        LIST[:pick_up_item].gsub(REGEXP[:item], item)
      end

      def get_on_item(item)
        LIST[:get_on_item].gsub(REGEXP[:item], item)
      end

      def put_item(item)
        LIST[:put_item].gsub(REGEXP[:item], item)
      end

      def drop_item(item)
        LIST[:drop_item].gsub(REGEXP[:item], item)
      end

      def lost_item(item)
        LIST[:lost_item].gsub(REGEXP[:item], item)
      end

      def equip_item(item)
        LIST[:equip_item].gsub(REGEXP[:item], item)
      end

      def remove_item(item)
        LIST[:remove_item].gsub(REGEXP[:item], item)
      end

      def stolen_item(item)
        LIST[:stolen_item].gsub(REGEXP[:item], item)
      end

      def item_hit_to(item, to)
        map = {ITEM => item, TO => to}
        LIST[:item_hit_to].gsub(REGEXP[:item_to], map)
      end

      def wait_and_see(attacker)
        LIST[:wait_and_see].gsub(REGEXP[:attacker], attacker)
      end

      def warped(attacker)
        LIST[:warped].gsub(REGEXP[:attacker], attacker)
      end

      [
       :hp,
       :power,
       :stomach,
      ].each do |param|
        recover = "#{param}_recover".to_sym
        define_method(recover) do |point|
          LIST[recover].gsub(REGEXP[:point], point.to_s)
        end

        gain = "#{param}_gain".to_sym
        define_method(gain) do |point|
          LIST[gain].gsub(REGEXP[:point], point.to_s)
        end
      end

      def status_recover(status_sym)
        status_name = STATUS_NAMES[status_sym]
        LIST[:status_recover].gsub(REGEXP[:status], status_name)
      end

      def anti_status(target, status_sym)
        status_name = STATUS_NAMES[status_sym]
        map = {TO => target, STATUS => status_name}
        LIST[:anti_status].gsub(REGEXP[:to_status], map)
      end
    end

    extend ModuleMethods
  end
end

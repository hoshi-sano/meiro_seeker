require 'yaml'
YAML::ENGINE.yamler = 'psych'

module MyDungeonGame
  module MessageManager
    LIST =
      YAML.load(File.read(MESSAGE_LIST_PATH)).
      merge(YAML.load(File.read(WORD_LIST_PATH)))

    PLAYER = 'p'
    LEVEL = 'l'
    ITEM = 'i'
    FROM = 'f'
    TO = 't'
    POINT = 'p'
    ATTACKER = 'a'

    REGEXP = {
      to:            Regexp.new("#{TO}"),
      point:         Regexp.new("#{POINT}"),
      attacker:      Regexp.new("#{ATTACKER}"),
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

      def kill(target)
        LIST[:kill].gsub(REGEXP[:to], target)
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
    end

    extend ModuleMethods
  end
end

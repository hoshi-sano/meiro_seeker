require 'yaml'
YAML::ENGINE.yamler = 'psych'

module MyDungeonGame
  module MessageManager
    LIST = YAML.load(File.read(MESSAGE_LIST_PATH))

    PLAYER = 'p'
    LEVEL = 'l'
    FROM = 'f'
    TO = 't'
    POINT = 'p'
    ATTACKER = 'a'

    REGEXP = {
      to:            Regexp.new("#{TO}"),
      point:         Regexp.new("#{POINT}"),
      attacker:      Regexp.new("#{ATTACKER}"),
      from_point:    Regexp.new("[#{FROM}#{POINT}]"),
      player_level:  Regexp.new("[#{PLAYER}#{LEVEL}]"),
      from_to_point: Regexp.new("[#{FROM}#{TO}#{POINT}]"),
    }.freeze

    module_function

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
  end
end

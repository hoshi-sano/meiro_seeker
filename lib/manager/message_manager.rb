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

    module_function

    def attack(from, to, damage)
      map = {FROM => from, TO => to, POINT => damage.to_s}
      LIST[:attack].gsub(Regexp.new("[#{FROM}#{TO}#{POINT}]"), map)
    end

    def damage(damage)
      LIST[:damage].gsub(Regexp.new("#{POINT}"), damage.to_s)
    end

    def from_damage(from, damage)
      map = {FROM => from, POINT => damage}
      LIST[:from_damage].gsub(Regexp.new("[#{FROM}#{POINT}]"), map)
    end

    def kill(target)
      LIST[:kill].gsub(Regexp.new("#{TO}"), target)
    end

    def missed(attacker)
      LIST[:attacker_missed].gsub(Regexp.new("#{ATTACKER}"), attacker)
    end
  end
end

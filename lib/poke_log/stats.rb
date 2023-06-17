# frozen_string_literal: true

module PokeLog
  class Stats < Hash
    def initialize(hash=nil)
      super

      hash ||= { hp: 0, atk: 0, def: 0, spa: 0, spd: 0, spe: 0 }

      Stats.verify(hash)

      Stats.stats.each do |s|
        self[s] = hash[s]
      end
    end

    def +(other)
      return self if other.nil?

      Stats.verify other, strict: false
      merge(other) { |_, old, new| old + new }
    end

    def -(other)
      return self if other.nil?

      Stats.verify other, strict: false
      merge(other) { |_, old, new| old - new }
    end

    def hp
      self[:hp]
    end

    def atk
      self[:atk]
    end

    def def
      self[:def]
    end

    def spa
      self[:spa]
    end

    def spd
      self[:spd]
    end

    def spe
      self[:spe]
    end

    def self.stats
      %i[hp atk def spa spd spe]
    end

    def self.consumables_for(stat)
      {
        hp: {
          vitamin: :hp_up,
          feather: :health,
          berry: :pomeg
        },
        atk: {
          vitamin: :protein,
          feather: :muscle,
          berry: :kelpsy
        },
        def: {
          vitamin: :iron,
          feather: :resist,
          berry: :qualot
        },
        spa: {
          vitamin: :calcium,
          feather: :genius,
          berry: :hondew
        },
        spd: {
          vitamin: :zinc,
          feather: :clever,
          berry: :grepa
        },
        spe: {
          vitamin: :carbos,
          feather: :swift,
          berry: :tamato
        }
      }[stat.to_s.sub(/_ev/, "").to_sym]
    end

    def self.verify(hash, strict: true)
      if (strict && hash.keys.sort != Stats.stats.sort) ||
         !hash.keys.all? { |s| Stats.stats.include? s }
        raise ArgumentError.new, "invalid stats keys"
      end

      if hash.keys.uniq.length != hash.keys.length
        raise ArgumentError.new, "duplicate stats in one entry"
      end

      unless hash.values.all? { |n| n.is_a? Integer }
        raise ArgumentError.new, "invalid stats values"
      end
    end
  end
end

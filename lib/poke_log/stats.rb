module PokeLog
  class Stats < Hash
    def self.stats
      %i[hp atk def spa spd spe]
    end

    def self.verify(hash, strict=true)
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

    def initialize(hash)
      Stats.verify(hash)

      Stats.stats.each do |s|
        self[s] = hash[s]
      end
    end

    def +(addend)
      Stats.verify addend, false
      self.merge!(addend) { |_, old, new| old + new }
    end

    def -(subtrahend)
      Stats.verify subtrahend, false
      self.merge!(subtrahend) { |_, old, new| old - new }
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
  end
end

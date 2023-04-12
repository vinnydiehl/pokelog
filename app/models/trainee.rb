# frozen_string_literal: true

class Trainee < ApplicationRecord
  belongs_to :user
  has_many :kills

  PokeLog::Stats.stats.each do |stat|
    validates :"#{stat}_ev", numericality: {in: 0..255}
  end
  validates :level, numericality: {in: 1..100}, allow_nil: true

  def set_attributes(data)
    if (species = Species.find_by_display_name data["species"])
      self.species_id = species.id
    elsif data["species"].blank?
      self.species_id = nil
    end

    %w[ev goal].each do |name|
      if PokeLog::Stats.stats.map { |s| data["#{s}_#{name}"].to_i }.inject(:+) <= 510
        PokeLog::Stats.stats.each do |stat|
          send "#{stat}_#{name}=", [data["#{stat}_#{name}"].to_i, 0, 255].sort[1]
        end
      end
    end

    self.nickname, self.nature, self.level =
      data["nickname"], data["nature"], data["level"]
    self.pokerus = data["pokerus"].to_i.nonzero?
    self.item = data["item"] == "on" ? nil : data["item"]
  end

  def title
    if nickname.blank?
      species.blank? ? "New Trainee" : species.name
    else
      species.blank? ? nickname : "#{nickname} (#{species.name})"
    end
  end

  def species
    Species.find_by_id species_id
  end

  def evs
    PokeLog::Stats.new({
      hp: hp_ev,
      atk: atk_ev,
      def: def_ev,
      spa: spa_ev,
      spd: spd_ev,
      spe: spe_ev
    })
  end

  def goals
    PokeLog::Stats.new({
      hp: hp_goal,
      atk: atk_goal,
      def: def_goal,
      spa: spa_goal,
      spd: spd_goal,
      spe: spe_goal
    })
  end
end

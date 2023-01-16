class Trainee < ApplicationRecord
  belongs_to :user
  has_many :kills
  attr_accessor :species

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

    self.nickname, self.nature, self.level =
      data["nickname"], data["nature"], data["level"]
    self.pokerus = data["pokerus"].to_i.nonzero?
    PokeLog::Stats.stats.each do |stat|
      send "#{stat}_ev=", [data["#{stat}_ev"].to_i, 0, 255].sort[1]
    end
    self.item = data["item"] == "on" ? nil : data["item"]
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
end

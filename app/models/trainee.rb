class Trainee < ApplicationRecord
  belongs_to :user
  has_many :kills
  attr_accessor :species

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

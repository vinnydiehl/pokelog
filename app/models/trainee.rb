class Trainee < ApplicationRecord
  belongs_to :user
  has_many :kills

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :species, shortcuts: %i[id]

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

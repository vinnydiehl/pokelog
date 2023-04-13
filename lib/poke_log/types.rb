# frozen_string_literal: true

module PokeLog
  class Types
    def self.types
      %i[normal fighting flying poison ground rock bug ghost steel
         fire water grass electric psychic ice dragon dark fairy]
    end

    # Get the damage multiplier of an attack based on type.
    #
    # @param atk_type [Symbol] the type of the attack
    # @param def_types [Array<Symbol>] the type(s) of the defender
    # @return [Numeric] the damage multiplier (0, 0.5, 1, 2, or 4)
    def self.multiplier(atk_type, def_types)
      # Create a table to store type matchups- for now they're set to 1x
      type_matchups = Hash[types.map do |attacker|
        [attacker, Hash[types.map { |defender| [defender, 1] }]]
      end]

      # Now to fill in all of the non-1 values on the table:

      # Immunities
      [
        %i[normal ghost],
        %i[fighting ghost],
        %i[poison steel],
        %i[ground flying],
        %i[ghost normal],
        %i[electric ground],
        %i[psychic dark],
        %i[dragon fairy]
      ].each do |attacker, defender|
        type_matchups[attacker][defender] = 0
      end

      # Strengths
      [
        *%i[normal rock steel ice dark].map { |d| [:fighting, d] },
        *%i[fighting rock steel ice dark].map { |d| [:flying, d] },
        *%i[grass fairy].map { |d| [:poison, d] },
        *%i[poison rock steel fire electric].map { |d| [:ground, d] },
        *%i[flying bug fire ice].map { |d| [:rock, d] },
        *%i[grass psychic dark].map { |d| [:bug, d] },
        *%i[ghost psychic].map { |d| [:ghost, d] },
        *%i[rock ice fairy].map { |d| [:steel, d] },
        *%i[bug steel grass ice].map { |d| [:fire, d] },
        *%i[ground rock fire].map { |d| [:water, d] },
        *%i[ground rock water].map { |d| [:grass, d] },
        *%i[flying water].map { |d| [:electric, d] },
        *%i[fighting poison].map { |d| [:psychic, d] },
        *%i[flying ground grass dragon].map { |d| [:ice, d] },
        [:dragon] * 2,
        *%i[ghost psychic].map { |d| [:dark, d] },
        *%i[fighting dragon dark].map { |d| [:fairy, d] }
      ].each do |attacker, defender|
        type_matchups[attacker][defender] = 2
      end

      # Resistances
      [
        *%i[rock steel].map { |d| [:normal, d] },
        *%i[flying poison bug psychic fairy].map { |d| [:fighting, d] },
        *%i[rock steel electric].map { |d| [:flying, d] },
        *%i[poison ground rock ghost].map { |d| [:poison, d] },
        *%i[bug grass].map { |d| [:ground, d] },
        *%i[fighting ground steel].map { |d| [:rock, d] },
        *%i[fighting flying poison ghost steel fire fairy].map { |d| [:bug, d] },
        %i[ghost dark],
        *%i[steel fire water electric].map { |d| [:steel, d] },
        *%i[rock fire water dragon].map { |d| [:fire, d] },
        *%i[water grass dragon].map { |d| [:water, d] },
        *%i[flying poison bug steel fire grass dragon].map { |d| [:grass, d] },
        *%i[grass electric dragon].map { |d| [:electric, d] },
        *%i[steel psychic].map { |d| [:psychic, d] },
        *%i[steel fire water ice].map { |d| [:ice, d] },
        %i[dragon steel],
        *%i[fighting dark fairy].map { |d| [:dark, d] },
        *%i[poison steel fire].map { |d| [:fairy, d] }
      ].each do |attacker, defender|
        type_matchups[attacker][defender] = 0.5
      end

      # Look up the types on the table and multiply across each defensive type
      def_types.reduce(1) do |multiplier, def_type|
        multiplier * type_matchups[atk_type][def_type]
      end
    end
  end
end

module StatsHelper
  def format_stat(stat)
    {
      hp: "HP",
      atk: "Atk",
      def: "Def",
      spa: "Sp.A",
      spd: "Sp.D",
      spe: "Spe"
    }[stat]
  end
end

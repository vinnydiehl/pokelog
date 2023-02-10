module StatsHelper
  def format_stat(stat)
    {
      hp: "HP",
      atk: "Atk",
      def: "Def",
      spa: "Sp.A",
      spd: "Sp.D",
      spe: "Spe"
    }[stat.to_s.sub(/_ev/, "").to_sym]
  end
end

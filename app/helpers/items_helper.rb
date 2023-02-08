module ItemsHelper
  # Table of tooltips for the items on trainees#show
  #
  # @param item [String] name of the item (per DB enum/image name)
  # @return [String] the tooltip for that item
  def item_tooltip(item)
    {
      "macho_brace" => "Doubles EV gains in all stats",
      "power_weight" => "+4 HP EVs with every kill",
      "power_bracer" => "+4 Atk EVs with every kill",
      "power_belt" => "+4 Def EVs with every kill",
      "power_lens" => "+4 Sp.A EVs with every kill",
      "power_band" => "+4 Sp.D EVs with every kill",
      "power_anklet" => "+4 Spe EVs with every kill"
    }[item]
  end
end

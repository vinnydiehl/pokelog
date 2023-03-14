module ItemsHelper
  # Table of tooltips for the items on trainees#show
  #
  # @param item [String] name of the item (per DB enum/image name)
  # @return [String] the tooltip for that item
  def item_tooltip(item, generation)
    dict = { "weight" => "HP", "bracer" => "Atk", "belt" => "Def",
             "lens" => "Sp.A", "band" => "Sp.D", "anklet" => "Spe" }

    if dict.has_key?(item.split("_")[1])
      "+#{generation > 6 ? 8 : 4} #{dict[item.split('_')[1]]} EVs with every kill"
    elsif item == "macho_brace"
      "Doubles EV gains in all stats"
    end
  end
end

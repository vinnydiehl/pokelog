def open_consumables_menu
  find(".collapsible-header .expand").click
  sleep 0.5
end

# @param cases [Hash] test cases in format `item_type: [start_value, expected_result]`
def test_consumables(**cases)
  # item_type is :vitamins, :feathers, or :berries
  cases.each do |item_type, test_cases|
    describe "#{item_type}:" do
      STATS.each do |stat|
        item = PokeLog::Stats.consumables_for(stat)[item_type.to_s.singularize.to_sym]

        describe "#{item.to_s.humanize.downcase}" do
          test_cases.each do |start_value, expected_value|
            context "with #{start_value} #{format_stat stat}" do
              difference = expected_value - start_value
              action = difference < 0 ? "subtracts" : "adds"

              it "#{action} #{difference.abs} #{format_stat stat} EVs" do
                set_ev stat, start_value unless start_value.zero?
                find(".#{item_type} .#{item}").click
                wait_for stat, expected_value

                expect(Trainee.first.send stat).to eq expected_value
              end
            end
           end
        end
      end
    end
  end
end

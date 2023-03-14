module Capybara
  module Node
    class Element
      def hover_and_click
        hover
        sleep 0.1
        click
      end
    end
  end
end

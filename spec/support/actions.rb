module Capybara
  module Node
    class Element
      # Fix for some stubborn elements causing intermittent tests on slower
      # machines. Try this if you have problems with click accuracy.
      def hover_and_click
        2.times do
          hover
          sleep 0.1
        end

        click
      end
    end
  end
end

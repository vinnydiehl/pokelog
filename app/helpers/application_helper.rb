module ApplicationHelper
  # Generates a nav link for the sidenav, with an icon and optional text.
  #
  # @param icon [String] material-icons ligature
  # @param path [String] target path
  # @param text [String] text (for wide sidebar)
  # @return [String] HTML for the sidenav li element
  def nav_link(icon, path, text = "")
    attrs = { class: "bold" }

    attrs[:class] << " active" if current_page?(path)

    content_tag(:li, attrs) do
      link_to path, class: "waves-effect" do
        content_tag(:i, icon, class: "material-icons").concat(content_tag :div, text)
      end
    end
  end

  # Numeric inputs ignore the maxlength property. This bit of JS gets around that.
  # Splat it onto your options, like:
  #
  #   = form.text_field :level, type: "number", min: 1, max: 100, **maxlength(3)
  #
  # @param n [Integer] number of characters to limit input to
  # @return [Hash] option to pass to #text_field to limit characters
  def maxlength(n)
    { onKeyPress: "if (this.value.length > #{n - 1}) return false;" }
  end
end

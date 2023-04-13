# frozen_string_literal: true

module ApplicationHelper
  # Gets the current PokéLog version
  #
  # @return [String] current version number
  def version
    File.read(Rails.root / "VERSION")
  end

  # Generates a human-readable amount of time since the server was started.
  #
  # @return [String] amount of server uptime in plain English
  def uptime
    time_ago_in_words PokeLog::BOOTED_AT, include_seconds: true
  end

  # Generates a human-readable amount of time since the app was deployed.
  # Uses the modification time of the "app" directory.
  #
  # @return [String] amount of time since app was deployed in plain English
  def time_since_deploy
    time_ago_in_words File.mtime("app"), include_seconds: true
  end

  # Generates JavaScript for the onclick of a nav link. This ensures that the sidenav
  # closes
  #
  # @param path [String] the path to link to
  # @return [String] JavaScript to close the sidenav and redirect to the path
  def nav_link_js(path)
    "if (window.innerWidth <= 992) {" \
      "M.Sidenav.getInstance(document.querySelector('#sidenav')).close();" \
      "window.location.href = '#{path}'" \
    "} else Turbo.visit('#{path}')"
  end

  # Generates a nav link for the sidenav, with an icon and optional text.
  #
  # @param icon [String] material-icons ligature
  # @param path [String] target path
  # @param text [String] text (for wide sidebar)
  # @return [String] HTML for the sidenav li element
  def nav_link(icon, path, text = "")
    attrs = { class: "bold#{request.path.starts_with?(path) ? ' active' : ''}" }

    content_tag(:li, attrs) do
      content_tag(:a, onclick: nav_link_js(path), class: "waves-effect") do
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
  # @param js [String] additional code for the oninput attribute
  # @return [Hash] option to pass to #text_field to limit characters
  def maxlength(n, js=nil)
    { oninput: "if(this.value.length>#{n - 1}) this.value=this.value.slice(0,#{n});#{js}" }
  end

  # Builds a page title (as displayed e.g. in the browser tab) based on the title
  # from the topnav. If on the homepage this will simply be "PokéLog", otherwise
  # it will have a "|" separating it from the remainder of the title.
  #
  # @param title [String] the title from `yield :title`
  # @param path [String] the current request.path
  # @return title formatted for the browser
  def build_title(title, path)
    "PokéLog#{
      (title.blank? || %w[/ /home /index].include?(path)) ? '' : " | #{title}"
    }"
  end
end

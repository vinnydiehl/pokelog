module ApplicationHelper
  def nav_link(icon, path, text = "")
    attrs = { class: "bold" }

    attrs[:class] << " active" if current_page?(path)

    content_tag(:li, attrs) do
      link_to path, class: "waves-effect" do
        content_tag(:i, icon, class: "material-icons").concat(content_tag :div, text)
      end
    end
  end
end

module PagesHelper
  def tutorial_image(name)
    if name.ends_with?(".webm")
      method = :video_tag
      attrs = {autoplay: true, loop: true}
    else
      method = :image_tag
      attrs = {}
    end

    send(method, "/images/tutorial/full/#{name}", class: "tutorial-img full", **attrs) +
      send(method, "/images/tutorial/mobile/#{name}", class: "tutorial-img mobile", **attrs)
  end
end

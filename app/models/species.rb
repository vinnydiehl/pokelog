class Species < ActiveYaml::Base
  set_root_path Rails.root.join("data")

  # @return [Integer] National Dex ID
  def int_id
    self[:id].match(/\d+/).to_s.to_i
  end

  # @return [String] National Dex ID with leading zeros
  def pretty_id
    self[:id].match(/\d+/).to_s
  end

  # @return [String] HTML image tag for the artwork
  def artwork
    ActionController::Base.helpers.image_tag "/images/artwork/#{self[:id]}.png",
      class: "artwork"
  end

  # @return [String] HTML image tag for the sprite
  def sprite
    ActionController::Base.helpers.image_tag "/images/sprites/#{self[:id]}.png",
      class: "sprite"
  end

  # @return [String] path to the sprite
  def sprite_path
    "/images/sprites/#{self[:id]}.png"
  end

  # @return [Hash] EV yields that are > 0
  def yields
    self[:ev_yield].select { |_, y| y > 0 }
  end

  # @return [Boolean] whether or not it has multiple forms
  def has_forms?
    self[:form].present?
  end
end

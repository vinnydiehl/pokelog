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

  # Formats the name of the species for use in the autocomplete select in
  # the trainee info. Hisuian Voltorb, for example, returns
  # "Voltorb (Hisuian)". Normal forms are not specified.
  #
  # @return [String] display name for the species
  def display_name
    "#{self[:name]}#{[nil, "Normal"].include?(self[:form]) ? "" : " (#{self[:form]})"}"
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

  # See app/assets/stylesheets/types.scss
  #
  # @return [String] HTML div tags for type badges
  def type_badges(**args)
    types.map do |type|
      "<div class='type#{args[:size] == :large ? ' large' : ''} #{type}'></div>"
    end.join.html_safe
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

  # Finds the species specified by the display name in the autocomplete select
  # in the trainee info.
  #
  # @return [Species] the species that matches the display name, or nil
  def self.find_by_display_name(name)
    form = nil
    if name[/\(/]
      form = name[/(?<=\()[^\)]+/]
      name = name.split("(").first.strip
    end
    find { |s| s.name == name && (s.form == form || (form == nil && s.form == "Normal")) }
  end

  # Search form logic for displaying species
  #
  # @param params [Hash] parameters from query string
  # @param generation [String] the generation cookie (can be nil)
  # @param show_all_by_default [Boolean] whether or not to show
  # @return [Array<Species>] the species that satisfy the query and filters
  def self.search(params, generation, show_all_by_default=false)
    results = all

    if generation
      results = results.select { |pkmn| pkmn.generations.include? generation.to_i }
    end

    # If there's no query or params, show either all or nothing depending on options
    if [(query = params[:q]), (filters = params[:filters] || [])].all?(&:blank?)
      return show_all_by_default ? results : []
    end

    if filters.present?
      # Amount yielded
      range = (filters[:min] || 1).to_i..(filters[:max] || 3).to_i
      results = results.select do |pkmn|
        pkmn.yields.values.any? { |v| range.include? v }
      end

      # EVs yielded
      if filters[:yielded]
        filters[:yielded].map! &:to_sym
        results.select! do |pkmn|
          pkmn.yields.keys.any? { |stat| filters[:yielded].include? stat }
        end
      end

      # Types
      if filters[:types]
        filters[:types].map! &:to_sym
        results.select! do |pkmn|
          filters[:types].all? { |type| pkmn.types.include? type }
        end
      end

      # Weak to
      if filters[:weak_to]
        filters[:weak_to].map! &:to_sym
        results.select! do |pkmn|
          filters[:weak_to].any? { |type| PokeLog::Types.multiplier(type, pkmn.types) > 1 }
        end
      end
    end

    if query.present?
      results = results.select { |pkmn| pkmn.name.downcase.include? query.downcase }
    end

    results
  end
end

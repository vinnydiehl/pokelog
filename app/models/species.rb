class Species < ActiveYaml::Base
  set_root_path Rails.root.join("data")

  def int_id
    self[:id].match(/\d+/).to_s.to_i
  end

  def yields
    self[:ev_yield].select { |_, y| y > 0 }
  end
end

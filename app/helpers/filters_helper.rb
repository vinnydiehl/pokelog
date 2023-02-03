module FiltersHelper
  # Gets the value of the desired filter. Returns nil if the filter does
  # not exist, or if there are no filters set.
  #
  # @param [String] filter key
  # @return [String] filter value, or nil
  def filter_value(filter)
    params["filters"] ? params["filters"][filter] : nil
  end

  # Determines if a checkbox filter has been checked.
  #
  # @param [String] filter key
  # @return [Boolean] whether or not the filter is checked
  def filter_checked?(filter, value)
    params["filters"] && params["filters"][filter] &&
      params["filters"][filter].include?(value.to_s)
  end
end

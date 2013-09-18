module LiquidFilters
  def rgb_alpha(rgb, alpha)
    rgb.to_s.gsub("rgb", "rgba").gsub(")", ", #{alpha})")
  end
end
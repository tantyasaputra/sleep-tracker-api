module ParamHelper
  def self.positive_integer(value, default)
    value = value.to_i rescue 0
    value.positive? ? value : default
  end
end

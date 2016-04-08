class AbstractModel < ActiveRecord::Base
  self.abstract_class = true

  def save
    raise ValidationException.new(self) if invalid?
    apply_default_values
    super
  end

  def apply_default_values
    self.class.defaults.each do |attribute, param|
      next unless self.send(attribute).nil?
      value = param.respond_to?(:call) ? param.call(self) : param
      self[attribute] = value
    end
  end

  class << self
    def default(attribute, value = nil, &block)
      defaults[attribute] = value
      # Allow the passing of blocks
      defaults[attribute] = block if block_given?
    end

    def defaults
      @defaults ||= {}
    end
  end
end
# frozen_string_literal: true

# Load the new Lightspeed module
require 'lightspeed'

# Backward compatibility - create Vend as an alias to Lightspeed
# Don't use 'module Vend' or we'll overwrite the alias!
Vend = Lightspeed

# Extend the Vend module (which is actually Lightspeed) with deprecation warnings
Vend.singleton_class.class_eval do
  @deprecation_warning_shown = false

  alias_method :configure_without_warning, :configure

  define_method(:configure) do |&block|
    unless @deprecation_warning_shown
      warn "[DEPRECATION] The 'Vend' constant is deprecated. " \
           "Please use 'Lightspeed' instead and update your require to 'require \"lightspeed\"'. " \
           "This compatibility shim will be removed in v1.0.0."
      @deprecation_warning_shown = true
    end

    configure_without_warning(&block)
  end
end

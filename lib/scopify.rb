require 'scopify/scope'

module Scopify
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def scoped(options)
      Scope.build(self, options)
    end

    def scope(name, options)
      meta_class = (class << self; self; end)
      meta_class.send(:define_method, name) do
        if options.is_a?(Scope)
          options
        else
          scoped(options)
        end
      end
    end
  end
end
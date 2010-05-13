require 'scopify/scope'

module Scopify
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def scoped(options)
      Scope.new(self, options)
    end
  end
end
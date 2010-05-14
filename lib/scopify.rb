require 'scopify/scope'

module Scopify
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def scoped(options)
      Scope.build(self, options)
    end

    # overwrite tis to enable your custom scopes
    def return_scope?(method_name)
      respond_to?("#{method_name}_scope_options")
    end

    def scope(name, options)
      # give access to current options inside of evaled method
      meta_class = (class << self; self; end)
      meta_class.send(:define_method, "#{name}_scope_options") do
        options
      end

      class_eval <<-CODE
        def self.#{name}(*args)
          options = #{name}_scope_options
          if options.is_a?(Proc)
            scoped(options.call(*args))
          elsif options.is_a?(Scope)
            options
          else
            scoped(options)      
          end
        end
      CODE
    end
  end
end
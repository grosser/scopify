Add named scopes and chainable scopes to any Object / Model.

 - As gem: ` sudo gem install scopify `
 - As Rails plugin: ` rails plugin install git://github.com/grosser/scopify.git `

Usage
=====

### scoped
Create a scope on the fly.
    MyDBWrapper.scoped(:limit => 10).scoped(:order => "something").all(:offset => 1)
    --> MyDBWrapper.all receives: {:limit => 10, :order => "something", :offset => 1}

### scope
Create named scopes, with options, lambdas or other scopes
    class MyDBWrapper
      include Scopify
      scope :good, :conditions => {:good => true}
      scope :okay, good.scoped(:conditions => {:goodness => [1,2,3]}
      scope :goodness, lambda{|factor| {:conditions => {:goodness => factor}} }
    end

    MyDBWrapper.good.first
    MyDBWrapper.good.goodness(3).first

### scope_to_hash
Roll your own condition composing.
    # not good ?
    MyDBWrapper.scoped(:order => 'a').scoped(:order => 'b).all --> {:order => "a, b"}

    # roll your own !
    class MyDBWrapper
      def self.scope_to_hash(options)
        options.map do |key, values|
          value = case key
          when :limit, :offset then values.min
          when :order then values.join(' AND ')
          else values.join(', ')
          end
          [key, value]
        end
      end
    end

    # better now !
    MyDBWrapper.scoped(:order => 'a').scoped(:order => 'b).all --> {:order => "a AND b"}

### first
When calling first on and scope, `:limit => 1` will be added
    MyDBWrapper.scoped(:limit => 1).all == MyDBWrapper.first

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
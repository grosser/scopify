Add named scopes and chainable scopes to any Object / Model.

 - As gem: ` sudo gem install scopify `
 - As Rails plugin: ` rails plugin install git://github.com/grosser/scopify.git `

Usage
=====

### With framework:
 - MongoMapper  
    MongoMapper::Document::ClassMethods.send(:include, Scopify::ClassMethods)
    MongoMapper::Plugins::Associations::Proxy.send(:include, Scopify::ClassMethods)
 - Add another ;)

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

### simple_scope
Defines otherwise repetitive named scopes for you.

    simple_scope :limit, :order, :where => :conditions
    --> MyDBWrapper.limit(3).order('foo').where("1 = 2") == 
        {:limit => 3, :order => 'foo', :conditions => "1 = 2"}


### Custom scope helpers
    class MyDBWrapper
      def self.foo(num)
        scoped(:foo => num)
      end

      def self.bar(num)
        scoped(:bar => num)
      end

      # tell scopes to pass raw arguments to foo and bar (not merged options hash)
      def self.raw_args_from_scope?(method_name)
        return true if super
        [:foo, :bar].include?(method_name)
      end
    end

    MyDBWrapper.foo(1).bar(3) == MyDBWrapper.scoped(:foo => 1, :bar => 3)

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



Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
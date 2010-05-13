Add named scopes and scoped to any Object / Model.

Usage
=====

`scope` -- create named scopes, with options, lambdas or even other scopes!
    class MyDBWrapper
      include Scopify
      scope :good, :conditions => {:good => true}
      scope :okay, good.scoped(:conditions => {:goodness => [1,2,3]}
      scope :goodness, lambda{|factor| {:conditions => {:goodness => factor}} }
    end

    MyDBWrapper.good.first
    MyDBWrapper.good.goodness(3).first

`scoped` -- create a scope on the fly
    MyDBWrapper.scoped(:limit => 10).scoped(:order => "something").all(:offset => 1)
    --> MyDBWrapper.all receives: {:limit => 10, :order => "something", :offset => 1}

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
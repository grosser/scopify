Add named scopes and scoped to any Object / Model.

Setup
=====
    class CrazyNewDatabaseWrapper
      include Scopify
      scopify

      scope :good, :conditions => {:good => true}
    end

Usage
=====
    # if all is implemented on CrazyNewDatabaseWrapper, you can use:
    CrazyNewDatabaseWarpper.scoped(:limit => 10).scoped(:order => "something").all

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
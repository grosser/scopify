require 'spec/spec_helper'

class T1
  include Scopify

  def self.foo(options)
    options
  end

  def self.first(options)
    options
  end
end

class T2
  include Scopify

  def self.foo(options)
    options
  end

  def self.scope_to_hash(options)
    hash = {}
    options.each do |k,v|
      hash[k] = v[0]+v[1]
    end
    hash
  end
end

describe Scopify do
  describe :scoped do
    it "returns a new scope" do
      T1.scoped({}).class.should == Scopify::Scope
    end

    it "can call anything on scope to reach base" do
      T1.scoped({:limit => 1}).foo.should == {:limit => 1}
    end

    it "adds limit => 1 to first queries" do
      T1.scoped({:order => 'FOO'}).first.should == {:limit => 1, :order => 'FOO'}
    end

    it "can stack" do
      T1.scoped(:limit => 1).scoped(:order => 'X').foo.should == {:limit => 1, :order => 'X'}
    end

    it "overwrites limit with the minimum" do
      T1.scoped(:limit => 1).scoped(:limit => 2).foo.should == {:limit => 1}
      T1.scoped(:limit => 2).scoped(:limit => 1).foo.should == {:limit => 1}
    end

    it "overwrites offset with the minimum" do
      T1.scoped(:offset => 1).scoped(:offset => 2).foo.should == {:offset => 1}
      T1.scoped(:offset => 2).scoped(:offset => 1).foo.should == {:offset => 1}
    end

    it "can use custom scope_to_hash" do
      T2.scoped(:offset => 1).scoped(:offset => 2).foo.should == {:offset => 3}
    end
  end
end
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
    options.map do |k,v|
      [k, v[0]+v[1]]
    end
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

    it "can call anything giving additional options" do
      T1.scoped({:limit => 1}).foo(:offset => 1).should == {:limit => 1, :offset => 1}
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

    it "does not mess with arrays" do
      T2.scoped(:x => [[1]]).scoped(:x => [[2]]).scope_options.should == {:x => [[[1]], [[2]]]}
    end
  end

  describe :scope do
    it "adds a named scope" do
      T1.scope(:yyy, :limit => 1)
      T1.yyy.foo.should == {:limit => 1}
    end

    it "can add a scoped scope" do
      T1.scope(:xxx, :limit => 1)
      T1.scope(:xxx2, T1.xxx.scoped(:offset => 1))
      T1.xxx2.foo.should == {:limit => 1, :offset => 1}
    end

    it "can add scope with arguments" do
      T1.scope(:aaa, lambda{|a| {:limit => a}})
      T1.aaa(1).foo.should == {:limit => 1}
    end

    it "can stack scopes by name" do
      T1.scope(:bbb, :limit => 1)
      T1.scope(:bbb2, :offset => 1)
      T1.bbb.bbb2.foo.should == {:limit => 1, :offset => 1}
    end

    it "keeps oder when stacking by name" do
      T1.scope(:ccc, :order => 'a')
      T1.scope(:ccc2, :order => 'b')
      T1.ccc2.ccc.foo.should == {:order => 'b, a'}
    end
  end
end
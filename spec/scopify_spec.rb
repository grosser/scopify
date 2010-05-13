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
  end
end
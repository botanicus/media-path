# coding: utf-8

require File.join(File.dirname(__FILE__), "spec_helper")
require "path"

describe Path do
  before do
    @path = Path.new("public")
  end

  describe "#initialize" do
    it "should take absolute path or path relative from Merb.root" do
      @path.should eql(Path.new("#{Merb.root}/public"))
    end

    it "should works with both foo and foo/" do
      @path.should eql(Path.new("public/"))
    end

    it "should raise exception when the path not exist" do
      lambda { Path.new("i/do/not/exist/at/all") }.should raise_error
    end
  end

  describe "#==" do
    it "should be true if both paths has same absolute path" do
      @path.should eql(Path.new("public"))
    end

    it "should be false if both paths has different absolute path" do
      @path.should_not eql(Path.new("app"))
    end
  end

  describe "#absolute" do
    it "should returns absolute path" do
      @path.absolute.should eql("#{Merb.root}/public")
    end

    it "should returns existing path" do
      File.exist?(@path.absolute).should be_true
    end
  end

  describe "#relative" do
    it "should returns relative path" do
      @path.relative.should eql("public")
    end

    it "should returns existing path" do
      File.exist?(@path.relative).should be_true
    end
  end

  describe "#server" do
    it "should raise exception when it tries to link files out of public directory" do
      path = Path.new("app")
      lambda { path.server }.should raise_error
    end

    it "should returns relative path" do
      @path.server.should eql("/")
    end
  end
end

# coding: utf-8

require_relative "../lib/path"

describe MediaPath do
  before do
    @root = File.expand_path("spec/stubs/blog")
    @relative = "public/js/moo.js"
    @absolute = File.join(@root, @relative)
    MediaPath.root = @root
    MediaPath.media_directory = File.join(@root, "public")
    @path = MediaPath.new(@absolute)
  end

  describe "#initialize" do
    it "should take absolute path or path relative from MediaPath.root" do
      MediaPath.new(@absolute).should eql(MediaPath.new(@relative))
    end

    it "should works with both foo and foo/" do
      MediaPath.new("#{@absolute}/").path.should_not match(Regexp.new("/$"))
    end

    it "should raise exception when the path not exist" do
      lambda { MediaPath.new("i/do/not/exist/at/all") }.should raise_error
    end

    it "should raise exception if MediaPath.root isn't defined" do
      MediaPath.root = nil
      lambda { MediaPath.new(@absolute) }.should raise_error
    end
  end

  describe "#==" do
    it "should be true if both paths has same absolute path" do
      @path.should eql(MediaPath.new(@relative))
    end

    it "should be false if both paths has different absolute path" do
      @path.should_not eql(MediaPath.new(Dir.pwd))
    end
  end

  describe "#absolute" do
    it "should be absolute" do
      @path.absolute.should match(%r[^(/|[A-Z]://)])
    end

    it "should returns existing path" do
      File.exist?(@path.absolute).should be_true
    end
  end

  describe "#relative" do
    it "should returns relative path" do
      @path.relative.should eql(@relative)
    end

    it "should returns existing path" do
      Dir.chdir(@root) do
        File.exist?(@path.relative).should be_true
      end
    end

    it "should returns empty string if MediaPath.root and path to file is the same" do
      @path.root = @path.absolute
      @path.relative.should eql("")
    end
  end

  describe "#url" do
    it "should raise exception when it tries to link files out of public directory" do
      path = MediaPath.new(Dir.pwd)
      lambda { path.url }.should raise_error
    end

    it "should returns absolute URL" do
      @path.url.should eql("/js/moo.js")
    end

    it "should raise exception if MediaPath.media_directory isn't defined" do
      MediaPath.media_directory = nil
      lambda { @path.url }.should raise_error
    end
  end

  describe ".rewrite" do
    it "should modified URL" do
      MediaPath.rewrite { |url| "http://101ideas.cz" + url }
      @path.url.should eql("http://101ideas.cz/js/moo.js")
    end

    it "should be FIFO" do
      MediaPath.rewrite { |url| url.tr("_", "-") }
      MediaPath.rewrite { |url| "#{url}_test" }
      @path.url.should match(/_/)
    end
  end
end

# coding: utf-8

require "lib/path"

describe Path do
  before do
    @root = File.expand_path("spec/stubs/blog")
    @relative = "public/js/moo.js"
    @absolute = File.join(@root, @relative)
    @path = Path.new(@absolute)
    Path.root = @root
    Path.media_directory = File.join(@root, "public")
  end

  describe "#initialize" do
    it "should take absolute path or path relative from Path.root" do
      Path.new(@absolute).should eql(Path.new(@relative))
    end

    it "should works with both foo and foo/" do
      Path.new("#{@absolute}/").path.should_not match(Regexp.new("/$"))
    end

    it "should raise exception when the path not exist" do
      lambda { Path.new("i/do/not/exist/at/all") }.should raise_error
    end

    it "should raise exception if Path.root isn't defined" do
      Path.root = nil
      lambda { Path.new(@absolute) }.should raise_error
    end
  end

  describe "#==" do
    it "should be true if both paths has same absolute path" do
      @path.should eql(Path.new(@relative))
    end

    it "should be false if both paths has different absolute path" do
      @path.should_not eql(Path.new(Dir.pwd))
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
  end

  describe "#url" do
    it "should raise exception when it tries to link files out of public directory" do
      path = Path.new(Dir.pwd)
      lambda { path.url }.should raise_error
    end

    it "should returns absolute URL" do
      @path.url.should eql("/js/moo.js")
    end

    it "should raise exception if Path.media_directory isn't defined" do
      Path.media_directory = nil
      lambda { @path.url }.should raise_error
    end
  end

  describe ".rewrite" do
    it "should modified URL" do
      Path.rewrite { |url| "http://101ideas.cz" + url }
      @path.url.should eql("http://101ideas.cz/js/moo.js")
    end

    it "should be FIFO" do
      Path.rewrite { |url| url.tr("_", "-") }
      Path.rewrite { |url| "#{url}_test" }
      @path.url.should match(/_/)
    end
  end
end

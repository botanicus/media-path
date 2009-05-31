# coding: utf-8

class Path
  class << self
    attr_accessor :root
  end
  self.root = Dir.pwd

  attr_reader :absolute

  # Path.new("public/uploads")
  # Path.new("#{Merb.root}/public/uploads")
  # @since 0.0.1
  def initialize(path)
    raise ArgumentError.new("Argument for creating new Path must be string") unless path.is_a?(String)
    raise ArgumentError.new("Path can't be empty string") if path.empty?
    # no trailing /
    path.chomp!("/")
    if path.match(%r{^/}) || path.match(%r[^[A-Z]//]) # / or C://
      @absolute = File.expand_path(path)
    else
      @absolute = File.expand_path(File.join(Path.root, path))
    end
    raise "File does not exist: '#{@absolute}'" unless File.exist?(@absolute)
  end

  # @since 0.0.1
  def relative
    path = @absolute.dup
    path[Path.root + "/"] = String.new
    return path
  end

  # @since 0.0.1
  def url
    path = @absolute.dup
    path[Project.root] = String.new
    path
  end

  # # @since 0.0.1
  # def server
  #   # match public/, but replace just public
  #   # we need to match directory public, but server path must starts with /
  #   # change: we can get just public which 1) do not work with our regexp 2) have no slash, so it will returns just "", so we add trailing slash to end:
  #   if relative.match(%r{^public$})
  #     return "/"
  #   elsif relative.match(%r{^public/})
  #     return relative.sub(%r{^public}, '')
  #   else
  #     raise "Ty ty ty!, fuj to je!"
  #   end
  # end

  # @since 0.0.1
  def ==(another)
    raise TypeError unless another.is_a?(self.class)
    @absolute == another.absolute
  end
  alias_method :eql?, :==

  # @since 0.0.1
  def join(*segments)
    raise ArgumentError if segments.any? { |segment| not segment.is_a?(String) }
    raise ArgumentError if segments.any? { |segment| segment.match(%r{^/}) }
    Path.new(File.join(@absolute, *segments))
  end

  # @since 0.0.1
  def +(segment)
    raise ArgumentError unless segment.is_a?(String)
    raise ArgumentError if segment.match(%r{^/})
    Path.new("#@absolute/#{segment}")
  end

  # Dir["#{path}/*"]
  # @since 0.0.1
  alias_method :to_s, :absolute

  # @since 0.0.1
  def entries
    Dir["#@absolute/*"].map do |path|
      self.class.new(path)
    end
  end

  # @since 0.0.1
  def inspect
    %["file://#@absolute"]
  end

  # @since 0.0.1
  def basename
    File.basename(@absolute)
  end

  # # Use instead of File.open("foo", "w")
  # def self.write(file, &block)
  #   self.open(file, "w", &block)
  # end
  #
  # # Use instead of File.open("foo", "r")
  # def self.read(file, &block)
  #   self.open(file, "r", &block)
  # end
  #
  # # Use instead of File.open("foo", "a")
  # def self.append(file, &block)
  #   self.open(file, "a", &block)
  # end
  #
  # # Use instead of File.open("foo", "w+")
  # def self.rewrite(file, &block)
  #   self.open(file, "w+", &block)
  # end
  #
  # @since 0.0.1
  def write(&block)
    File.open(file, "w", &block)
  end

  # @since 0.0.1
  def read(&block)
    if block_given?
      File.open(@absolute, "r", &block)
    else
      File.read(@absolute)
    end
  end

  # @since 0.0.1
  def append(&block)
    File.open(file, "a", &block)
  end

  # @since 0.0.1
  def rewrite(&block)
    File.open(file, "w+", &block)
  end

  # Pathname("x.html.erb").extname
  # => ".erb"
  # @since 0.0.1
  def extension(file)
    self.to_s[/\.\w+?$/] # html.erb.
    # return @path.last.sub(/\.(\w+)$/, '\1') # dalsi moznost
  end

  # @since 0.0.1
  def extension=(extension)
    if @path.last.match(/\./)
      return Path[self[0..-1] + @path.last.sub(/\.\w+$/, ".#{extension}")]
    else
      return @path[-1] = "#{@path.last}.#{extension}"
    end
  end

  # @since 0.0.1
  def to_a
    return self.to_s.split("/")
  end

  # @since 0.0.1
  def without_extension
    return self.to_s.sub(/#{extension}$/, '')
  end

  # @since 0.0.1
  def without_extension!
    return self.to_s.sub!(/#{extension}$/, '')
  end

  # alias_method :childrens, :children
  # @since 0.0.1
  def make_executable
    File.chmod(0755, @filename)
  end

  # @since 0.0.1
  def make_unexecutable
    File.chmod(0644, @filename)
  end

  # @since 0.0.1
  def run(command)
    Dir.chdir(self) do
      return %x(#{command})
    end
  end

  # @since 0.0.1
  def exist?
    File.exist?(@absolute)
  end

  # @since 0.0.1
  def load
    Kernel.load(@absolute)
  end

  # @since 0.0.1
  def hidden?
    self.basename.to_s.match(/^\./).to_bool
  end

  # dir/foo/../ => dir/
  # @since 0.0.1
  def normalize
    @filename.gsub!(/[^\/]+\/\.{2}/, "")
  end

  # @since 0.0.1
  def empty?
    (self.directory? and self.children.empty?) || File.zero?()
  end

  # @since 0.0.1
  def md5(file)
    require 'digest/md5'
    Digest::MD5.hexdigest(File.read(file))
  end

  # @since 0.0.1
  def self.without_extension(file)
    return file.sub(/\.\w+$/, '')
  end

  # @since 0.0.1
  def self.basename_without_extension(file)
    return File.basename(file.sub(/\.\w+$/, ''))
  end

  # @since 0.0.1
  def self.change_extension(file, extension)
    return file.sub(/\.\w+$/, ".#{extension}")
  end
end

# coding: utf-8

class MediaPath
  # @since 0.0.1
  def self.first_file(*choices)
    choices.find { |file| File.file?(File.expand_path(file)) }
  end

  # @since 0.0.1
  def self.first_directory(*choices)
    choices.find { |file| File.directory?(File.expand_path(file)) }
  end

  # @since 0.0.1
  def self.check_directory_path(path)
    return if path.nil? # because of exceptions
    raise ArgumentError.new("MediaPath can't be created from empty string") if path.empty?
    path = File.expand_path(path)
    raise ArgumentError, "MediaPath '#{path}' doesn't exist" unless File.directory?(path)
    return path
  end

  # @since 0.0.1
  def self.media_root
    @media_root
  end

  def self.media_root=(path)
    @media_root = self.check_directory_path(path)
  end

  # @since 0.0.1
  def self.root
    @root ||= Dir.pwd
  end

  # @since 0.0.1
  def self.root=(path)
    @root = self.check_directory_path(path)
  end

  # @since 0.0.1
  def self.rewrite_rules
    @rewrite_rules ||= Array.new
  end

  def self.rewrite_rules=(rules)
    @rewrite_rules = rules
  end

  self.rewrite_rules ||= Array.new

  # @since 0.0.1
  # @note It make problems in case of reloading
  def self.rewrite(&rule)
    # @@rewrite_rules.push(&rule) # WTF?
    @rewrite_rules += [rule]
  end

  # @since 0.0.1
  attr_reader :absolute

  # @since 0.0.1
  alias_method :path, :absolute

  # @since 0.0.1
  attr_accessor :root, :media_root

  # MediaPath.new("public/uploads")
  # MediaPath.new("#{Merb.root}/public/uploads")
  # @since 0.0.1
  def initialize(path)
    self.root = self.class.root
    raise ArgumentError.new("Argument for creating new MediaPath must be string") unless path.is_a?(String)
    raise ArgumentError.new("MediaPath can't be created from empty string") if path.empty?
    path.chomp!("/") unless path == "/" # no trailing /
    if path.match(%r{^/}) || path.match(%r[^[A-Z]//]) # / or C://
      @absolute = File.expand_path(path)
    else
      @absolute = File.expand_path(File.join(self.class.root, path))
    end
    raise Errno::ENOENT, "File does not exist: '#{@absolute}'" unless File.exist?(@absolute)
  end

  # @since 0.0.1
  def root
    @root || Dir.pwd
  end

  # @since 0.0.1
  def media_root
    @media_root ||= self.class.media_root
    return @media_root unless @media_root.nil?
    raise "#{self.class}#media_root can't be nil! If you like setup media_root for all instances, use #{self.class}.media_root" if @media_root.nil?
  end

  # @since 0.0.1
  def media_root=(path)
    @media_root = self.class.check_directory_path(path)
  end

  # @since 0.0.1
  def root=(path)
    @root = self.class.check_directory_path(path)
  end

  # @since 0.0.1
  def relative
    path = @absolute.dup
    path[self.root] = String.new
    path.sub!(%r[^/], "")
    return path
  end

  # @since 0.0.1
  def parent
    parent = File.expand_path(File.join(@absolute, ".."))
    MediaPath.new(parent)
  end

  # @since 0.0.1
  def url
    url = @absolute.dup
    url[self.media_root] = String.new
    rules = self.class.rewrite_rules
    rules.empty? ? url : rules.map { |rule| url = rule.call(url) }.last
  end

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
    self.class.new(File.join(@absolute, *segments))
  end

  # @since 0.0.1
  def +(segment)
    raise ArgumentError unless segment.is_a?(String)
    raise ArgumentError if segment.match(%r{^/})
    self.class.new("#@absolute/#{segment}")
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

  # @since 0.0.1
  def write(&block)
    File.open(@absolute, "w", &block)
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
    File.open(@absolute, "a", &block)
  end

  # @since 0.0.1
  def rewrite(&block)
    File.open(@absolute, "w+", &block)
  end

  # MediaPathname("x.html.erb").extname
  # => ".erb"
  # @since 0.0.1
  def extension(file)
    self.to_s[/\.\w+?$/] # html.erb.
    # return @path.last.sub(/\.(\w+)$/, '\1') # dalsi moznost
  end

  # @since 0.0.1
  def to_a
    return self.to_s.split("/")
  end

  # @since 0.0.1
  def without_extension
    return self.to_s.sub(/#{extension}$/, '')
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

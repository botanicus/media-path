#require "path"
# TODO:from easyruby, but it's not done yet

class Path
  attr_reader :absolute
  # Path.new("public/uploads")
  # Path.new("#{Merb.root}/public/uploads")
  def initialize(path)
    path = path.absolute if path.is_a?(Path) # TODO: spec it
    raise ArgumentError unless path.is_a?(String) # TODO: spec it
    # no trailing /
    path.sub!(%r{/$}, "")
    if path.match(%r{^/})
      @absolute = File.expand_path(path)
    else
      @absolute = File.expand_path(File.join(Merb.root, path))
    end
    raise unless File.exist?(@absolute)
  end

  def relative
    path = @absolute.dup
    path[Merb.root + "/"] = String.new
    return path
  end

  def server
    # match public/, but replace just public
    # we need to match directory public, but server path must starts with /
    # change: we can get just public which 1) do not work with our regexp 2) have no slash, so it will returns just "", so we add trailing slash to end:
    if relative.match(%r{^public$})
      return "/"
    elsif relative.match(%r{^public/})
      return relative.sub(%r{^public}, '')
    else
      raise "Ty ty ty!, fuj to je!"
    end
  end

  def ==(another)
    raise TypeError unless another.is_a?(self.class)
    @absolute == another.absolute
  end
  alias_method :eql?, :==

  # TODO: spec it
  def join(*segments)
    raise ArgumentError if segments.any? { |segment| not segment.is_a?(String) }
    raise ArgumentError if segments.any? { |segment| segment.match(%r{^/}) }
    Path.new(File.join(@absolute, *segments))
  end

  # TODO: spec it
  def +(segment)
    raise ArgumentError unless segment.is_a?(String)
    raise ArgumentError if segment.match(%r{^/})
    Path.new("#@absolute/#{segment}")
  end

  # TODO: spec it
  # Dir["#{path}/*"]
  alias_method :to_s, :absolute

  # TODO: spec it
  def entries
    Dir["#@relative/*"].map do |path|
      self.class.new(path)
    end
  end

  # TODO: spec it
  def inspect
    %{"file://#@relative"}
  end

  # TODO: spec it
  def basename
    File.basename(@absolute)
  end
end

# encoding: utf-8

desc "Build the gem"
task :build do
  sh "gem build media-path.gemspec"
end

namespace :build do
  desc "Build the prerelease gem"
  task :prerelease do
    gemspec = "media-path.gemspec"
    content = File.read(gemspec)
    prename = "#{gemspec.split(".").first}.pre.gemspec"
    # 0.1.1 => 0.2
    version = MediaPath::VERSION.sub(/^(\d+)\.(\d+\.){2}.*$/) { "#$1.#{$2.to_i + 1}" }
    puts "Current #{MediaPath::VERSION} => #{version} pre"
    File.open(prename, "w") do |file|
      file.puts(content.gsub(/(\w+::VERSION)/, "'#{version}.pre'"))
    end
    sh "gem build #{prename}"
    rm prename
  end
end

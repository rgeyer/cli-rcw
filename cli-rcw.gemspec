Gem::Specification.new do |gem|
  gem.name = "cli-rcw"
  gem.version = "0.0.1"
  gem.homepage = "https://github.com/rgeyer/cli-rcw"
  gem.license = "MIT"
  gem.summary = %Q{Simple CLI tool for interacting with RightScale Cloud Workflow}
  gem.description = gem.summary
  gem.email = "me@ryangeyer.com"
  gem.authors = ["Ryan J. Geyer"]
  gem.executables << "cli-rcw"

  gem.add_dependency("right_api_client", "= 1.5.13")
  gem.add_dependency("thor", "~> 0.18.1")

  gem.files = Dir.glob("{lib,bin}/**/*") + ["LICENSE", "README.md"]
end
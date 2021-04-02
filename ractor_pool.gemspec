require_relative 'lib/ractor_pool/version'

Gem::Specification.new do |spec|
  spec.name          = "ractor_pool"
  spec.version       = RactorPool::VERSION
  spec.authors       = ["Gleb Sinyavskiy"]
  spec.email         = ["zhulik.gleb@gmail.com"]

  spec.summary       = %q{A worker pool based on ractor.}
  spec.description   = %q{A worker pool based on ractor.}
  spec.homepage      = "https://github.com/zhulik/ractor_pool"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zhulik/ractor_pool"
  spec.metadata["changelog_uri"] = "https://github.com/zhulik/ractor_pool/blob/main/CHANGELOG.md"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "guard-svg2png"
  spec.version       = "0.0.3"
  spec.authors       = ["Seb Pollard"]
  spec.email         = ["seb.p@haygarth.co.uk"]
  spec.description   = %q{Converts SVG files to PNGs (For IE8)}
  spec.summary       = %q{Converts SVG files to PNGs (For IE8)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

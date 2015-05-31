# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'my_ebook_pub/version'

Gem::Specification.new do |spec|
  spec.name          = "my_ebook_pub"
  spec.version       = MyEbookPub::VERSION
  spec.authors       = ["Dave Haeffner"]
  spec.email         = ["dhaeffner@gmail.com"]
  spec.summary       = %q{A simple ebook creator. Turns Markdown files into PDF, EPUB, and MOBI with a linked table of contents.}
  spec.description   = %q{Based on Pete's Keen approach https://github.com/peterkeen/mmp-builder from his Adventures in Self Publishing https://www.petekeen.net/adventures-in-self-publishing}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "gimli", "~> 0.5.7"
  spec.add_dependency "docverter", "~> 1.0.1"
  spec.add_dependency "redcarpet", "~> 3.2.2"
  spec.add_dependency "pygments.rb", "~> 0.6.3"
end

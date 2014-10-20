# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'image_rotator/version'

Gem::Specification.new do |spec|
  spec.name          = "image_rotator"
  spec.version       = ImageRotator::VERSION
  spec.authors       = ["Benjamin Schaefer"]
  spec.email         = ["benjamin.schaefer@werbeboten.de"]
  spec.summary       = %q{ contains a jQuery plugin that handles rotation of 
                       images, including sprite animations. }
  spec.description   = %q{ This gem allows you to rotate any html content in the 
                       DOM object. It's destined for images. You can also use it 
                       for sprite animations. The easing is selectable. Also, 
                       rotation blurring is available. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

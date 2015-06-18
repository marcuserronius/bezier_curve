$: << File.expand_path("lib")
require "bezier_curve/version"

Gem::Specification.new do |s|
  s.name        = 'bezier_curve'
  s.version     = BezierCurve::VERSION
  s.date        = BezierCurve::RELEASE_DATE
  s.platform    = Gem::Platform::RUBY
  
  s.summary     = "N-dimensional, nth-degree bézier curves"
  s.description = "A bézier curve library for Ruby, supporting n-dimensional, nth-degree curves"
  s.license     = "MIT"
  s.author      = "Mark Hubbart"
  s.email       = "mark.hubbart@gmail.com"

  s.files       = Dir["{bin,lib,test}/**/*.{rb,md}"] + Dir["*.{md,rdoc}"] + ["Rakefile"]

  s.homepage    = "https://github.com/marcuserronius/bezier_curve"
end
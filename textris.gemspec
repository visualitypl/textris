lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name     = 'textris'
  spec.version  = '0.1.2'
  spec.authors  = ['Karol Słuszniak']
  spec.email    = 'k.sluszniak@visuality.pl'
  spec.homepage = 'http://github.com/visualitypl/textris'
  spec.license  = 'MIT'
  spec.platform = Gem::Platform::RUBY

  spec.summary = 'Simple SMS messaging gem for Rails based on concepts and conventions similar to ActionMailer, with some extra features.'

  spec.description = "Implement texter classes for sending SMS messages in similar way to how e-mails are sent with ActionMailer-based mailers. Take advantage of e-mail proxying and enhanced phone number parsing, among others."

  spec.files            = Dir["lib/**/*.rb"]
  spec.has_rdoc         = false
  spec.extra_rdoc_files = ["README.md"]
  spec.require_paths    = ["lib"]

  spec.add_runtime_dependency('render_anywhere', '>= 0.0.10')
  spec.add_runtime_dependency('actionmailer', '>= 4.0.0')
end

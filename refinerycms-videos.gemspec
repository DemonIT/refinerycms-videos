# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-videos'
  s.version           = '1.0.2'
  s.authors           = ['Ulyanov Dmitry']
  s.email             = ['demon@pglu.pro']
  s.description       = 'Manage videos in RefineryCMS. Use HTML5 Video.js player.'
  s.date              = '2014-02-17'
  s.summary           = 'Videos extension for Refinery CMS'
  s.require_paths     = %w(lib)
  s.files             = Dir['{app,config,db,lib,vendor}/**/*'] + %w(MIT-LICENSE Rakefile README.rdoc)
  s.post_install_message = 'RefineryCMS VideoJS installing!'

  # Runtime dependencies
  s.add_dependency             'refinerycms-core',    '~> 2.1.0'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 2.1.0'
end

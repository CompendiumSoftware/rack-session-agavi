# -*- encoding: utf-8 -*-
#
#

Gem::Specification.new do |s|

	s.name = 'rack-session-agavi'
	s.version = '0.1.4'

	s.authors = ['Stephen Gregory']
	s.date = '2013-04-24'
	s.description = "Agavi-compatible session management via rack"
	s.files = ['rack-session-agavi.gemspec', 'README', 'lib/rack-session-agavi.rb']
	s.summary = "use agavi sessions in rack based applications"
	s.add_dependency 'rack', '>= 1.5'
	s.add_dependency 'php-serialize', '>= 1.2.0'
    s.add_dependency 'dalli', '1.1.2'	
end

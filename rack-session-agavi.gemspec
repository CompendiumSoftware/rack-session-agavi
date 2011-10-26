# -*- encoding: utf-8 -*-
#
#

Gem::Specification.new do |s|

	s.name = 'rack-session-agavi'
	s.version = '0.1.3'

	s.authors = ['Stephen Gregory']
	s.date = '2011-10-06'
	s.description = "Agavi-compatible session management via rack"
	s.files = ['rack-session-agavi.gemspec', 'README', 'lib/rack-session-agavi.rb']
	s.summary = "use agavi sessions in rack based applications"
	s.add_dependency 'rack', '>= 1.0'
	s.add_dependency 'php-serialize', '>= 1.2.0'
    s.add_dependency 'dalli', '1.1.2'	
end

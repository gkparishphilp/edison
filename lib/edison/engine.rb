##### require gems here?
# require 'statsample'

module Edison
	class << self
		##### config vars
		#mattr_accessor :something

		#self.something = 'default'
	end

	# this function maps the vars from your app into your engine
	def self.configure( &block )
		yield self
	end



	class Engine < ::Rails::Engine
		isolate_namespace Edison

		##### send application controller stuff? copied from swell_media
		# initializer "edison.load_helpers" do |app|
		# 	ActionController::Base.send :include, Edison::ApplicationControllerExtensions
		# end

		##### setup rspec testing??? copied from swell_analytics
		config.generators do |g|
			g.test_framework :rspec, :fixture => false
			g.fixture_replacement :factory_girl, :dir => 'spec/factories'
			g.assets false
			g.helper false
		end

	end

end

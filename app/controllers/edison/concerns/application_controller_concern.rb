module Edison
	module Concerns

		module ApplicationControllerConcern
			extend ActiveSupport::Concern

			included do
				helper Edison::ApplicationHelper
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods


			protected

		end

	end
end

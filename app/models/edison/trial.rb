module Edison

	class Trial < ApplicationRecord
		
		belongs_to 	:bunyan_client
		belongs_to 	:experiment

		belongs_to	:variant, optional: true



		def generate_variant

			return self.variant if self.variant.present?

			case self.test.sample_type
			when 'weighted'
				# TODO
			when '5050'
				self.variant = self.test.variants.active.order( cached_participant_count: :desc ).first
			else # random
				self.variant = self.test.variants.active.order( "random()" ).first
			end

			self.save
			self.variant.increment( :cached_participant_count )

		end
		
	end

end
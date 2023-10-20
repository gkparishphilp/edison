module Edison

	class Trial < ApplicationRecord
		
		belongs_to 	:experiment

		belongs_to 	:client, class_name: 'Bunyan::Client', optional: true
		belongs_to	:variant, optional: true



		def generate_variant

			return self.variant if self.variant.present?

			case self.experiment.sample_type
			when 'weighted'
				# TODO
				stupid_array = []
				self.experiment.variants.each do |v|
					weight = v.weight < 1 ? v.weight * 10 : v.weight
					weight.times do
						stupid_array << v
					end
				end

				self.variant = stupid_array.sample

			when '5050'
				self.variant = self.experiment.variants.active.order( cached_participant_count: :asc ).first
			else # random
				self.variant = self.experiment.variants.active.order( Arel.sql("random()") ).first
			end

			self.save
			self.variant.increment!( :cached_participant_count )

		end
		
	end

end
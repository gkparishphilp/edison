module Edison

	class Experiment < ApplicationRecord
		has_many	:variants
		has_many 	:trials, through: :variants

		include FriendlyId
		friendly_id :name, use: :slugged

		
	end
	
end
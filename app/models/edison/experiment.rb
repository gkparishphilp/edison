module Edison

	class Experiment < ApplicationRecord

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => -1 }



		has_many	:variants
		has_many 	:trials, through: :variants

		include FriendlyId
		friendly_id :title, use: :slugged

		
	end
	
end
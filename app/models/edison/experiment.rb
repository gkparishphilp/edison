module Edison

	class Experiment < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }



		has_many	:variants
		has_many 	:trials, through: :variants#, source: :trial

		include FriendlyId
		friendly_id :title, use: :slugged

		
	end
	
end
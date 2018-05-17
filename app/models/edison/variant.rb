module Edison

	class Variant < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }

		belongs_to		:experiment

		has_many		:trials
		
	end
	
end
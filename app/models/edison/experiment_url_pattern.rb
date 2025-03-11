module Edison

	class ExperimentUrlPattern < ActiveRecord::Base
		belongs_to :experiment
	end

end

class EdisonTrialTrackingMigration < ActiveRecord::Migration[7.1]
	def change

		change_table :edison_trials do |t|
			t.string		:created_url
			t.boolean		:is_forced, default: false
		end

	end
end

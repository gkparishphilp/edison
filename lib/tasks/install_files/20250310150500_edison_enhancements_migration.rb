class EdisonEnhancementsMigration < ActiveRecord::Migration[7.1]
	def change

		create_table :edison_experiment_url_patterns do |t|
			t.belongs_to	:experiment
			t.string		:url_pattern
			t.timestamps
		end

	end
end

class EdisonCacGmMigration < ActiveRecord::Migration[7.1]
	def change
		change_table :edison_variants do |t|
			t.float "gross_margin", default: nil # a percent
			t.integer "cost_of_acquiring_customers", default: nil # cents
		end
		change_table :edison_experiments do |t|
			t.integer "conversion_window_days", default: 30
		end
	end
end

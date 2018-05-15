class EdisonMigration < ActiveRecord::Migration[5.1]
	def change

		create_table :edison_experiments, force: true do |t| # cache this model's attributes, and have it expire after session is dead for X minutes (TTL)
			t.string		:title
			t.string 		:slug
			t.text 			:description
			t.string		:sample_type, 	default: '5050'

			t.string 		:conversion_event

			t.datetime 		:start_at
			t.datetime 		:end_at
			t.integer 		:max_trials

			t.integer 		:status, 		default: 1

			t.hstore 		:properties

			t.timestamps
		end

		
		create_table :edison_variants, force: true do |t|
			t.references	:edison_experiment

			t.string		:title
			t.text 			:description
			t.string 		:variant_type, 					default: 'html' # image
			t.float 		:weight, 						default: 1
			t.text 			:content

			t.integer 		:status, 						default: 1

			t.integer 		:cached_participant_count, 		default: 0
			t.integer 		:cached_conversion_count, 		default: 0

			t.boolean 		:is_control # default variant, shown if experiment expires, etc.

			t.hstore		:properties

			t.timestamps
		end
		

		create_table :edison_trials, force: true do |t|
			t.references 	:edison_experiment
			t.references 	:edison_variant
			t.references 	:bunyan_client

			t.timestamps
		end

	end
end

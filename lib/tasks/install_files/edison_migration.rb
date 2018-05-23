class EdisonMigration < ActiveRecord::Migration[5.1]
	def change

		create_table :edison_experiments, force: true do |t| # cache this model's attributes, and have it expire after session is dead for X minutes (TTL)
			t.string		:title
			t.string 		:slug
			t.text 			:description

			t.string		:sample_type, 		default: '5050'
			# what to show when test is over
			t.string 		:conclusion_type, 	default: 'control' # winner, nothing

			t.string 		:conversion_event
			t.string 		:conversion_path

			t.datetime 		:start_at
			t.datetime 		:end_at
			t.integer 		:max_trials, 		default: 10000

			t.integer 		:status, 			default: 1

			t.hstore 		:properties

			t.timestamps
		end

		
		create_table :edison_variants, force: true do |t|
			t.references	:experiment

			t.string		:title
			t.text 			:description
			
			t.float 		:weight, 						default: 1
			t.text 			:content

			t.integer 		:status, 						default: 1

			t.integer 		:cached_participant_count, 		default: 0
			t.integer 		:cached_conversion_count, 		default: 0

			t.integer 		:final_participant_count,		default: 0
			t.integer 		:final_conversion_count,		default: 0

			t.boolean 		:is_control # default variant, shown if experiment expires, etc.

			t.hstore		:properties

			t.timestamps
		end
		

		create_table :edison_trials, force: true do |t|
			t.references 	:experiment
			t.references 	:variant
			t.references 	:client

			t.timestamps
		end

	end
end

module Edison
	module ApplicationHelper

		def edison_run_experiment( exp_id )
			# check if a trial exists for this client
			trial = Trial.where( bunyan_client_id: cookies[:clientuuid], edison_experiment_id: exp_id ).last

			# create one if not - this will assign the client to a variant
			trial ||= Trial.create( bunyan_client_id: cookies[:clientuuid], edison_experiment_id: exp_id )

			# method should return the correct variant content ro be rendered as html
			variant = trial.generate_variant

			return variant.content

		end

	end
end

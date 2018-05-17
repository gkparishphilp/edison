module Edison
	module ApplicationHelper

		def edison_run_experiment( exp_id )

			begin
				experiment = Experiment.friendly.find( exp_id )
			rescue ActiveRecord::RecordNotFound
				return ''
			end
			
			# check if a trial exists for this client
			trial = experiment.trials.where( client_id: cookies[:clientuuid] ).last

			# create one if not - this will assign the client to a variant
			trial ||= Trial.create( experiment_id: experiment.id, client_id: cookies[:clientuuid] )

			# method should return the correct variant content ro be rendered as html
			variant = trial.generate_variant

			return variant.content

		end

	end
end

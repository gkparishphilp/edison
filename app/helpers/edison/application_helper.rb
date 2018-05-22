module Edison
	module ApplicationHelper

		def edison_run_experiment( exp_id )

			begin
				experiment = Experiment.friendly.find( exp_id )
			rescue ActiveRecord::RecordNotFound
				return ''
			end

			if experiment.concluded? || not( experiment.active? )
				# the music's over
				if experiment.conclusion_type == 'control'
					return experiment.variants.where( is_control: true ).last.content
				elsif experiment.conclusion_type == 'winner'
					return experiment.variants.order( cached_conversion_count: :desc ).first.content
				else
					return ''
				end
			end


			client = Bunyan::Client.find_by( uuid: cookies[:clientuuid] )

			# check if a trial exists for this client
			trial = experiment.trials.where( client_id: client.id ).last

			# create one if not - this will assign the client to a variant
			trial ||= Trial.create( experiment_id: experiment.id, client_id: client.id )

			# method should return the correct variant content ro be rendered as html
			variant = trial.generate_variant

			return variant.content

		end

	end
end

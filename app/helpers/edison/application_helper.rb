module Edison
	module ApplicationHelper

		def edison_run_experiment( exp_id, options = {} )
			options[:default] = '' unless options.has_key? :default

			begin
				experiment = Experiment.friendly.find( exp_id )
			rescue ActiveRecord::RecordNotFound
				return options[:default]
			end

			if experiment.started? && experiment.concluded?

				# the music's over
				if experiment.conclusion_type == 'control'
					return experiment.variants.where( is_control: true ).last.content
				elsif experiment.conclusion_type == 'winner'
					return experiment.variants.order( cached_conversion_count: :desc ).first.content
				else
					return options[:default]
				end

			elsif not( experiment.active? ) || not( experiment.started? )
				# the music hasn't started yet
				return options[:default]
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

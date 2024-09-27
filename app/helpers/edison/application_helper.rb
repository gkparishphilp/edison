module Edison
	module ApplicationHelper

		def edison_run_experiment( exp_id, options = {} )
			options[:default] = '' unless options.has_key? :default

			variant = nil

			begin
				experiment = Experiment.friendly.find( exp_id )
			rescue ActiveRecord::RecordNotFound
				return options[:default]
			end

			# option to force a variant
			# will return the variant whether or not experiment is active
			# client will not be put into the trial pool
			force_var = options.delete( :force_var )
			if force_var.present?
				variant = experiment.variants.where( is_control: true ).last if force_var == 'control'
				variant ||= experiment.variants.find_by( id: force_var )
			end
			# if force_var is invalid, method should coninute as normally.....

			client_id = Bunyan::Client.find_by( uuid: cookies[:clientuuid] ).try( :id )

			if client_id.nil?
				return options[:default]
			end

			# check if a trial exists for this client
			trial = experiment.trials.where( client_id: client_id ).last

			if trial.nil? && ( experiment.started? && experiment.concluded? )

				# the music's over
				if experiment.conclusion_type == 'control'
					return experiment.variants.where( is_control: true ).last.content
				elsif experiment.conclusion_type == 'winner'
					return experiment.variants.active.order( cached_conversion_count: :desc ).first.content
				else
					return options[:default]
				end

			elsif trial.nil? && ( not( experiment.active? ) || not( experiment.started? ) )
				# the music hasn't started yet
				return options[:default]
			end

			# create one if not - this will assign the client to a variant
			trial ||= Trial.create( experiment_id: experiment.id, client_id: client_id )

			if variant.present?
				trial.variant.decrement!( :cached_participant_count ) if trial.variant.present?
				variant.increment!( :cached_participant_count )
				trial.update( variant: variant )
			else
				# method should return the correct variant content ro be rendered as html
				variant = trial.generate_variant
			end

			return variant.content

		end

	end
end

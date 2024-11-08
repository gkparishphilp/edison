module Edison
	class ExperimentAdminController < ApplicationAdminController


		def create
			@experiment = Experiment.new( experiment_params )

			@experiment.start_at ||= Time.zone.now
			@experiment.end_at ||= @experiment.start_at + 1.month

			@experiment.save
			redirect_to edit_experiment_admin_path( @experiment )
		end

		def index
			@experiments = Experiment.all.order( created_at: :desc ).page( params[:page] )
		end

		def edit
			@experiment = Experiment.friendly.find( params[:id] )
			@control = @experiment.variants.control

		end

		def update
			@experiment = Experiment.friendly.find( params[:id] )
			@experiment.update( experiment_params )
			set_flash 'Experiment Updated'
			redirect_to edit_experiment_admin_path( @experiment )

		end


		private
			def experiment_params
				params.require( :experiment ).permit( :title, :description, :sample_type, :conclusion_type, :conversion_event, :conversion_path, :start_at, :end_at, :max_trials, :status, :conversion_window_days )
			end
	end
end

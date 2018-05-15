module Edison
	class ExperimentAdminController < SwellMedia::AdminController


		def create
			@experiment = Experiment.new( experiment_params )
			@experiment.save
			redirect_to edit_experiment_admin_path( @experiment )
		end

		def index
			@experiments = Experiment.all.order( created_at: :desc ).page( params[:page] )
		end

		def edit
			@experiment = Experiment.friendly.find( params[:id] )
		end

		def update
			@experiment = Experiment.friendly.find( params[:id] )
			@experiment.update( experiment_params )
			set_flash 'Experiment Updated'
			redirect_to edit_experiment_admin_path( @experiment )

		end


		private
			def experiment_params
				params.require( :experiment ).permit( :title, :description, :sample_type, :conversion_event, :start_at, :end_at, :max_trials, :status )
			end
	end
end
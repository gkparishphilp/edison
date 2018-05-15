module Edison
	class ExperimentAdminController < SwellMedia::AdminController


		def index
			@experiments = Experiment.all.order( created_at: :desc ).page( params[:page] )
		end

		def edit
			@experiment = Experiment.friendly.find( params[:id] )
		end
	end
end
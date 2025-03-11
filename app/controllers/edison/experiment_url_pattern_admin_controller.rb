module Edison
	class ExperimentUrlPatternAdminController < ApplicationAdminController


		def create
			@experiment_url_pattern = ExperimentUrlPattern.new( experiment_url_pattern_params )
			@experiment_url_pattern.save
			set_flash 'Experiment URL Pattern Created'
			redirect_to edit_experiment_admin_path( @experiment_url_pattern.experiment_id )
		end

		def destroy
			@experiment_url_pattern = ExperimentUrlPattern.find( params[:id] )
			@experiment_url_pattern.destroy
			set_flash 'Experiment URL Pattern Deleted'
			redirect_to edit_experiment_admin_path( @experiment_url_pattern.experiment_id )
		end

		def index
			@experiment_url_patterns = ExperimentUrlPattern.all.order( created_at: :desc ).page( params[:page] )
		end

		def edit
			@experiment_url_pattern = ExperimentUrlPattern.find( params[:id] )
		end

		def update
			@experiment_url_pattern = ExperimentUrlPattern.find( params[:id] )
			@experiment_url_pattern.update( experiment_url_pattern_params )
			set_flash 'Experiment URL Pattern Updated'
			redirect_to edit_experiment_admin_path( @experiment_url_pattern.experiment_id )

		end


		private
			def experiment_url_pattern_params
				params.require( :experiment_url_pattern ).permit( :experiment_id, :url_pattern )
			end
	end
end

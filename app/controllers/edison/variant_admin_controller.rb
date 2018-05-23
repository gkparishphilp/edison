module Edison
	class VariantAdminController < SwellMedia::AdminController

		def create
			@variant = Variant.new( variant_params )

			if Variant.where( experiment_id: @variant.experiment_id ).count == 0
				@variant.is_control = true
			end

			@variant.save
			redirect_to edit_variant_admin_path( @variant )
		end

		def destroy
			@variant = Variant.find( params[:id] )
			@variant.archive!
			redirect_back( fallback_location: '/admin' )
		end

		def edit
			@variant = Variant.find( params[:id] )
		end

		def update
			@variant = Variant.find( params[:id] )
			@variant.update( variant_params )

			if @variant.errors.present?
				set_flash @variant.errors.full_messages, :danger
			else
				Variant.where.not( id: @variant.id ).update_all( is_control: false ) if @variant.is_control?
			end

			redirect_back( fallback_location: '/admin' )
		end

		private

			def variant_params
				params.require( :variant ).permit( :experiment_id, :title, :description, :content, :status, :is_control )
			end

	end
end

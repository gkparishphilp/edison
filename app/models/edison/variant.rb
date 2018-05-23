module Edison

	class Variant < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }

		belongs_to		:experiment

		has_many		:trials


		def self.control
			where( is_control: true ).first
		end


		def confidence_interval( opts={} )
			return 0 if self.trials.empty?

			opts[:confidence] = opts[:confidence].to_s

			opts[:confidence] ||= '95' # 95% confidence
			confidence_factors = { '67' => 1, '75' => 1.15, '80' => 1.28, '90' => 1.645, '95' => 1.96, '99' => 2.575, '999' => 5 }
			confidence = confidence_factors[ opts[:confidence] ] || 1.96
			return Math.sqrt( self.conversion_rate( opts ) * ( 1 - self.conversion_rate( opts ) ) / self.trials.count ) * confidence
		end


		def conversion_rate( opts={} )
			return 0 if self.trials.empty?
			total_conversions = self.conversions( opts )
			return ( total_conversions.to_f / self.trials.count.to_f )
		end


		def conversions( opts={} )
			return 0 if self.trials.empty?
			event = opts[:event] || opts[:for] || self.experiment.conversion_event

			path = opts[:path] || opts[:page] || opts[:page_path] || self.conversion_path

			uniq = !!opts.fetch( :uniq, true )

			conversions = Bunyan::Event.where( name: event ).where( client_id: self.participants )

			# only include conversions from when the experiemnt actually started
			conversions = conversions.where( "created_at > :t", t: self.trials.minimum( :created_at ) )

			conversions = conversions.where( page_path: self.conversion_path ) if event == 'pageview' && self.conversion_path.present?

			conversions = conversions.distinct if uniq

			conversions = conversions.count
			
		end



		def participants
			Bunyan::Client.where( id: self.trials.pluck( :client_id ) )
		end
		
	end
	
end
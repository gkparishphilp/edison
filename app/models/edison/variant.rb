module Edison

	class Variant < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }

		belongs_to		:experiment

		has_many		:trials

		validate :is_control_toggle


		def self.control
			where( is_control: true ).first
		end


		def confidence_interval( opts={} )
			return 0 if trials_count.zero?

			opts[:confidence] = opts[:confidence].to_s

			opts[:confidence] ||= '90' # 90% confidence
			confidence_factors = { '67' => 1, '75' => 1.15, '80' => 1.28, '90' => 1.645, '95' => 1.96, '99' => 2.575, '999' => 5 }
			confidence = confidence_factors[ opts[:confidence] ] || 1.96
			rate = self.conversion_rate( opts )
			return Math.sqrt( rate * ( 1 - rate ) / trials_count ) * confidence
		end


		def conversion_rate( opts={} )
			return 0 if trials_count.zero?
			total_conversions = self.conversions( opts )
			return ( total_conversions.to_f / trials_count.to_f )
		end


		def conversions( opts={} )
			event = opts[:event] || opts[:for] || self.experiment.conversion_event

			path = opts[:path] || opts[:page] || opts[:page_path] || self.experiment.conversion_path

			uniq = !!opts.fetch( :uniq, true )

			# Memoize per (event, path, uniq) for the lifetime of this instance. The
			# admin view asks for the same variant's conversions 4-6x per row (directly,
			# and again inside conversion_rate / confidence_interval), and each call
			# used to re-run a COUNT over the huge bunyan_events table.
			@conversions_cache ||= {}
			cache_key = [ event, path, uniq ]
			return @conversions_cache[ cache_key ] if @conversions_cache.key?( cache_key )

			return ( @conversions_cache[ cache_key ] = 0 ) if trials_count.zero?

			conversions = Bunyan::Event.where( name: event ).where( client_id: self.participants )

			# only include conversions from when the experiemnt actually started
			conversions = conversions.where( "created_at >= :t", t: trials_started_at ) if trials_started_at

			if self.experiment.has_expired?
				# only include conversions from before the experiemnt ended
				conversions = conversions.where( "created_at <= :t", t: self.experiment.end_at )
			end

			conversions = conversions.where( page_path: path ) if event == 'pageview' && path.present?

			conversions = conversions.distinct if uniq

			@conversions_cache[ cache_key ] = conversions.count

		end



		def participants
			# Subquery form (select, not pluck) so the trial client_ids never get
			# materialized into a Ruby array — a big experiment has hundreds of
			# thousands of them, and that array became a giant SQL IN-list.
			Bunyan::Client.where( id: self.trials.select( :client_id ) )
		end

		# Memoized trial count — reused by conversion_rate, confidence_interval and
		# the admin view instead of re-running COUNT(*) on edison_trials each time.
		def trials_count
			@trials_count ||= self.trials.count
		end

		# Memoized earliest trial timestamp (nil when the variant has no trials).
		def trials_started_at
			return @trials_started_at if defined?( @trials_started_at )
			@trials_started_at = self.trials.minimum( :created_at )
		end

		protected

		def is_control_toggle
			if not( self.is_control? ) && self.is_control_changed? && self.experiment.variants.active.where( is_control: true ).where.not( id: self.id ).count == 0
				self.errors.add( :is_control, "can't be delesected.  To deselect a variant as control you must toggle it to a different variant." )
			end

			if self.is_control? && self.status_changed? && not( self.active? )
				self.errors.add( :status, "can't be non-active when set as control.  To change the status select another variant as control first." )
			elsif self.is_control? && not( self.active? )
				self.errors.add( :is_control, "can't be selected for a non-active variant." )
			end

		end

	end

end

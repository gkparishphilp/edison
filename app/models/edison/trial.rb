module Edison

	class Trial < ApplicationRecord

		belongs_to 	:experiment

		belongs_to 	:client, class_name: 'Bunyan::Client', optional: true
		belongs_to	:variant, optional: true


		# The client's trial in an experiment. The EARLIEST trial wins, so a
		# visitor's arm never changes even if a duplicate slipped in.
		def self.for_client( experiment, client_id )
			where( experiment_id: experiment.id, client_id: client_id ).order( :id ).first
		end

		# Enrolls a client in an experiment exactly once, and returns
		# [ trial, created ].
		#
		# One page load can fire several requests that each evaluate the same
		# experiment. A check-then-insert let every one of them create its own
		# trial with its own random variant, so the visitor was counted in every
		# arm (SHIRE-1126). The variant is now picked BEFORE the insert, and the
		# unique (experiment_id, client_id) index turns a losing racer's insert
		# into RecordNotUnique, which re-reads and returns the winner's trial.
		def self.enroll( experiment, client_id, attributes = {} )
			trial = new( { experiment_id: experiment.id, client_id: client_id }.merge( attributes ) )
			trial.experiment = experiment
			trial.variant ||= trial.pick_variant

			begin
				# savepoint, so a conflict doesn't abort a surrounding transaction
				transaction( requires_new: true ) { trial.save! }
			rescue ActiveRecord::RecordNotUnique
				existing = for_client( experiment, client_id )
				raise if existing.nil?
				return [ existing, false ]
			end

			trial.variant.increment!( :cached_participant_count ) if trial.variant.present?

			[ trial, true ]
		end


		# Assigns a variant to a trial that has none. Only the request that
		# actually assigns it counts the participant; a concurrent request that
		# loses gets the variant that won.
		def generate_variant

			return self.variant if self.variant.present?

			picked = pick_variant
			return nil if picked.nil?

			assigned = Trial.where( id: self.id, variant_id: nil ).update_all( variant_id: picked.id, updated_at: Time.now )

			if assigned == 1
				picked.increment!( :cached_participant_count )
				self.variant = picked
				clear_attribute_changes( [ :variant_id ] )
			else
				self.reload
			end

			self.variant
		end

		def pick_variant

			case self.experiment.sample_type
			when 'weighted'
				# TODO
				stupid_array = []
				self.experiment.variants.each do |v|
					weight = v.weight < 1 ? v.weight * 10 : v.weight
					weight.times do
						stupid_array << v
					end
				end

				stupid_array.sample

			when '5050'
				self.experiment.variants.active.order( cached_participant_count: :asc ).first
			else # random
				self.experiment.variants.active.order( Arel.sql("random()") ).first
			end

		end

	end

end

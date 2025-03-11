module Edison

	class Experiment < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }

		has_many	:experiment_url_patterns

		has_many	:variants
		has_many 	:trials, through: :variants#, source: :trial

		include FriendlyId
		friendly_id :title, use: :slugged

		def concluded?
			if self.has_expired?
				return true
			end

			if self.has_max_trials?
				self.end_at = Time.zone.now
				self.save
				return true
			end
		end

		def has_expired?( args = {} )
			args[:now] ||= Time.zone.now
			self.end_at.present? && args[:now] >= self.end_at
		end

		def has_max_trials?
			self.max_trials.present? && self.trials.count > self.max_trials
		end

		def started?( args = {} )
			args[:now] ||= Time.zone.now
			self.start_at.present? && args[:now] >= self.start_at
		end

	end

end

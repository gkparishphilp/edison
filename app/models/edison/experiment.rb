module Edison

	class Experiment < ApplicationRecord

		enum status: { 'archive' => -1, 'draft' => 0, 'active' => 1 }



		has_many	:variants
		has_many 	:trials, through: :variants#, source: :trial

		include FriendlyId
		friendly_id :title, use: :slugged

		def concluded?
			self.has_max_trials? || self.has_expired?
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
			self.start_at.present? && self.start_at >= args[:now]
		end

	end

end

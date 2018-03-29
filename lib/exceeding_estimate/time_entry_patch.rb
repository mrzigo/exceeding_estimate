module ExceedingEstimate
  module TimeEntryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        after_save :is_exceeding_estimate
      end
    end

    module InstanceMethods
      def is_exceeding_estimate
        return if issue.message_of_exceeding_estimate # Не отправлять если уже отправлено
        settings = Setting[:plugin_exceeding_estimate] || {}
        limit = (settings['limit'] || 0).to_i
        # если текущая оценка + лимит превышает запланированную, то
        if (issue.time_entries.map(&:hours).sum + limit) > issue.estimated_internal
            role_ids = (settings['roles'] || []).map(&:to_i)
            # puts '!!!estimate: ОТПРАВИТЬ!'
            # puts '!!!estimate: им:'
            # puts "!!! #{role_ids}"
            # puts '!!!'
            recipients = project. # Все те кому отправить письмо счастья
                         members.
                         joins(:roles).
                         where('roles.id in (?)', role_ids).
                         includes(:user).
                         uniq.
                         map(&:user)
            # puts "!!! #{recipients.map(&:name)}"
            # puts '!!!'
            # puts '!!!'

            recipients.each do |recipient|
              EstimateMailer.exceeding_estimate_mail(recipient, issue).deliver
            end
            issue.update_column(:message_of_exceeding_estimate, true)
        # else
        #     puts '!!! пока все в порядке'
        end
      end
    end
  end
end

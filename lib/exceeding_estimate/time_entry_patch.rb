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
        role_ids = (Setting.plugin_exceeding_estimate[:roles] || []).map(&:to_i)
        recipients = project. # Все те кому отправить письмо счастья
                     members.
                     joins(:roles).
                     where('roles.id in (?)', role_ids).
                     includes(:user).
                     uniq.
                     map(&:user)

        recipients.each do |recipient|
          EstimateMailer.exceeding_estimate_mail(recipient, issue).deliver
        end
        issue.update_column(:message_of_exceeding_estimate, true)
      end
    end
  end
end

module ExceedingEstimate
  module TimeEntryPatch
    def self.included(base)
      # base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_save :is_exceeding_estimate
      end
    end

    # module ClassMethods
    # end

    module InstanceMethods

      def is_exceeding_estimate
        need_save_issue = false
        new_time = issue.time_entries.map{|t| t.hours}.sum        # сумма трудозатрат пользователя()разработчика)
        estimated_internal = issue.estimated_internal             # Внутренняя оценка

        estimated_ratio = (Setting.plugin_efforts['max_ratio'] || 0).to_f   # минусуем время, которое не учитывается
        if estimated_internal - estimated_ratio > new_time           # если оценка больше трудозатрат
          issue.message_of_exceeding_estimate = false                # сбрасываем статус отправки сообщений
          issue.save
          return
        end

        return if issue.message_of_exceeding_estimate                # Не отправлять если уже отправлено

        # теперь мы понимаем, что превышена оценка трудозатрат, сообщаем всем выбранным ролям об этом
        role_ids = (Setting.plugin_exceeding_estimate[:roles] || []).map(&:to_i)
        recipients = project. # Все те кому отправить письмо счастья
                     members.
                     joins(:roles).
                     where('roles.id in (?)', role_ids).
                     includes(:user).
                     uniq.
                     map(&:user)

        recipients.each do |recipient|
          EstimateMailer.exceeding_estimate_mail(recipient, issue)
        end

      end
    end
  end
end

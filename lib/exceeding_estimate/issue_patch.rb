module ExceedingEstimate
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_save :message_status_check
      end
    end

    module InstanceMethods
      def message_status_check
        if self.estimated_internal != Issue.find_by_id(id).try(:estimated_internal) # изменилась оценка
          # puts '!!! ОЦЕНКа изменилась!'
          # puts '!!! с'
          # puts "!!! #{Issue.find_by_id(id).try(:estimated_internal)}"
          # puts '!!! на'
          # puts "!!! #{self.estimated_internal}"
          # puts "!!! запись новая?#{self.new_record?}"
          # puts '!!!'
          return if self.new_record?
          self.update_column(:message_of_exceeding_estimate, false)
        end
      end
    end

  end
end

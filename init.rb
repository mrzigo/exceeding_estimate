Redmine::Plugin.register :exceeding_estimate do
  name 'Exceeding Estimate'
  author 'DigitalWand (mr.zigo@yandex.ru)'
  description 'Уведомление о превышении оценки'
  version '0.1'
  url 'https://github.com/mrzigo/exceeding_estimate'
  author_url 'https://github.com/mrzigo'

  settings partial: 'exceeding_estimate/settings', default: {
    roles: [3, 9],                      # Для каких ролей присылаем уведомления 3-менеджер, 9-тимлид
    limit: 0,                           # Допуск, по которому можно превышать(+) или не допускать превышения(-)
  }

end

Rails.application.config.to_prepare do
  TimeEntry.send(:include, ExceedingEstimate::TimeEntryPatch)
end

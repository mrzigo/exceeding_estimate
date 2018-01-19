class CreateIssues < ActiveRecord::Migration
  def change
    add_column :issues, :message_of_exceeding_estimate, :boolean
  end
end

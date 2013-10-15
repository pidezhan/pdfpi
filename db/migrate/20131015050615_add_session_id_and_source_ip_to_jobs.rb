class AddSessionIdAndSourceIpToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :session_id, :string
    add_column :jobs, :source_ip, :string
  end
end

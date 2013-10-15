class AddDownloadLinkToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :download_link, :string
  end
end

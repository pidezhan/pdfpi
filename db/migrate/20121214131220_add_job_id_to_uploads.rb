class AddJobIdToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :job_id, :string
  end
end

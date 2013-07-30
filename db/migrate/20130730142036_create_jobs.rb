class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :job_type
      t.string :download_path
      t.datetime :expiry_date

      t.timestamps
    end
  end
end

class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer :job_id
      t.string :source_ip

      t.timestamps
    end
  end
end

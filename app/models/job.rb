class Job < ActiveRecord::Base
  attr_accessible :download_path, :expiry_date, :job_type
end

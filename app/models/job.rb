class Job < ActiveRecord::Base
  attr_accessible :download_path, :expiry_date, :job_type, :session_id, :source_ip, :download_link, :status
  
  has_many :downloads
end

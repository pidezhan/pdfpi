class Download < ActiveRecord::Base
  attr_accessible :job_id, :source_ip
  
  belongs_to :job
end

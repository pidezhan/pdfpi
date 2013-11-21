class Job < ActiveRecord::Base
  attr_accessible :download_path, :expiry_date, :job_type, :session_id, :source_ip, :download_link, :status
  
  has_many :downloads
  
  def self.keep_house
    # clean up uploads more than 1 week old
    
    too_old = 1.week.ago
    
    @uploads = Upload.where('created_at < ?', too_old)
    @uploads.each do |upload|
      file_path = File.join(Rails.root, 'public', 'system', 'uploads', upload.id.to_s)
      `rm -rf #{file_path}`
      logger.debug "#{file_path} removed"
      puts "#{file_path} removed"
    end
    
    @jobs = Job.where('created_at < ?', too_old)
    @jobs.each do |job|
      file_path = File.join(Rails.root, 'public', 'system', 'downloads', job.session_id)
      `rm -rf #{file_path}`
      logger.debug "#{file_path} removed"
      puts "#{file_path} removed"
    end
  end
  
end

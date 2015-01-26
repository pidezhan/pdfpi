class Job < ActiveRecord::Base
  attr_accessible :download_path, :expiry_date, :job_type, :session_id, :source_ip, :download_link, :status
  
  has_many :downloads
  
  def self.keep_house
    # clean up uploads and downloads more than 1 day old
    
    upload_too_old = 10.hours.ago
    download_too_old = 1.day.ago
    
    @uploads = Upload.where('created_at < ?', upload_too_old).reorder('created_at desc').take(1000)
    @uploads.each do |upload|
      file_path = File.join(Rails.root, 'public', 'system', 'uploads', upload.id.to_s)
      `rm -rf #{file_path}`
      # logger.debug "#{file_path} removed"
      # puts "#{file_path} removed"
    end
    
    @jobs = Job.where('created_at < ?', download_too_old).reorder('created_at desc').take(1000)
    @jobs.each do |job|
      file_path = File.join(Rails.root, 'public', 'system', 'downloads', job.session_id)
      `rm -rf #{file_path}`
      # logger.debug "#{file_path} removed"
      # puts "#{file_path} removed"
    end
  end
  
end

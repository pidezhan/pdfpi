class IntelController < ApplicationController
  layout "intel"
  
  def index
    @start_time = 1.year.ago
    
    jobs_OK_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :status => 'OK').
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_OK_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_OK_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
        
    jobs_error_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :status => 'ERROR').
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_error_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_error_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
  end
end

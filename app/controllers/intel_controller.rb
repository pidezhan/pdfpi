class IntelController < ApplicationController
  layout "intel"
  
  def index
    @start_time = 6.months.ago
    
    # OK jobs data
    jobs_OK_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :status => 'OK').
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_OK_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_OK_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
        
    # error jobs data
    jobs_error_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :status => 'ERROR').
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_error_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_error_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
        
    # split jobs data
    jobs_split_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :job_type => 'split', :status => ['OK', 'ERROR']).
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_split_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_split_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
        
    # combine jobs data
    jobs_combine_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :job_type => 'combine', :status => ['OK', 'ERROR']).
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_combine_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_combine_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
  
    # stamp jobs data
    jobs_stamp_by_day = Job.where(:created_at => @start_time.beginning_of_day..Time.zone.now.end_of_day, :job_type => 'stamp', :status => ['OK', 'ERROR']).
                        group("date(created_at)").
                        select("date(created_at) as created_at, count(*) as job_count")
    @job_stamp_count_data = (@start_time.to_date..Date.today).map do |date|
          job = jobs_stamp_by_day.detect { |job| job.created_at.to_date == date }
          job && job.job_count.to_f || 0
        end
  end
end

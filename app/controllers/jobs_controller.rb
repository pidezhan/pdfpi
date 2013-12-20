class JobsController < ApplicationController
  
  before_filter :authenticate, :only => [:index, :inspect]
  
  def index
    @jobs = Job.order("id desc").paginate(:page => params[:page], :per_page => 30)
  end

  def new
  end
  
  def show
    @job = Job.order('id desc').find_by_session_id(params[:id])
    if not @job
      redirect_to :action => 'invalid'
      return
    #elsif @job.expiry_date and @job.expiry_date < Time.now
    #  redirect_to :action => 'expired'
    #  return
    elsif @job.download_path and not File.exist?(@job.download_path)
      FeedbackMailer.auto_report(@job.id).deliver
      redirect_to :action => :p_error
    end
  end
  
  def inspect
    @job = Job.find(params[:id])
    @uploads = Upload.where(:job_id => @job.session_id)
    @downloads = @job.downloads if @job
  end
  
  def download
    @job = Job.order('id desc').find_by_session_id(params[:id])
    if not @job
      redirect_to :action => 'invalid'
      return
    #elsif @job.expiry_date and @job.expiry_date < Time.now
    #  redirect_to :action => 'expired'
    #  return
    elsif @job.download_path and File.exist?(@job.download_path)
      Download.create(:job_id => @job.id, :source_ip => request.remote_ip)
      content_type = (@job.job_type == 'split' ? 'application/zip' : 'application/pdf')
      send_file @job.download_path, :type => content_type, :filename => File.basename(@job.download_path)
    else #error handling
      FeedbackMailer.auto_report(@job.id).deliver
      redirect_to :action => :p_error
    end
  end
  
  # processing error
  def p_error
  end
  
  def expired
  end
  
  def invalid
  end
  
  def email
    if request.post?
      @job = Job.find(params[:job_id])
      @email = params[:email]
      @status = ""
      if @job and @email
        FeedbackMailer.send_link(download_job_url(@job.session_id), @email).deliver
        @status = "OK"
      else
        @status = "ERROR"
      end
      respond_to do |format|
        format.js
      end
      
    end
    
    
  end
  
  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "pdfpi123" and password = "funny123!"
    end
  end
end

class JobsController < ApplicationController
  
  before_filter :authenticate, :except => :download
  
  def index
    @jobs = Job.order("id desc").paginate(:page => params[:page], :per_page => 30)
  end

  def new
  end
  
  def download
    @job = Job.order('id desc').find_by_session_id(params[:id])
    if @job.download_path
      content_type = (@job.job_type == 'split' ? 'application/zip' : 'application/pdf')
      send_file @job.download_path, :type => content_type, :filename => File.basename(@job.download_path)
    else
      
    end
  end
  
  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "pdfpi123" and password = "funny123!"
    end
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :get_job_id
  helper_method :download_link_prefix
  helper_method :get_title
  helper_method :pdfbox_jar
  helper_method :max_file_size_combine
  
  def max_file_size_combine
    # in MB
    20
  end

  def get_download_valid_duration
    1.day
  end
  
  def get_job_id
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0...10).map{ o[rand(o.length)] }.join
    action_name + "_" + string + Time.now.to_i.to_s
  end
  
  def download_link_prefix
    if Rails.env.production?
      "http://www.pdfpi.com/"
    else
      "http://localhost:3000/"
    end
  end
  
  def pdfbox_jar
    if Rails.env.production?
      "/home/deployer/pdfbox/pdfbox-app-1.8.2.jar"
    else
      "/Users/yilin/pdfbox/pdfbox-app-1.8.2.jar"
    end
  end
  
  def get_title
    page_title = ""
    site_title = "Combine and split PDF online for free - pdfPi.com"
    if controller_name == "home"
      if action_name != "index"
        page_title = action_name.titleize
      end
    elsif controller_name == "feedback"
      page_title = "Feedback"
    elsif controller_name == "jobs" and action_name == "show"
      page_title = "Job success!"
    else
      page_title = action_name.titleize
    end
    page_title.length > 0 ? page_title + " | " + site_title : site_title
  end
end

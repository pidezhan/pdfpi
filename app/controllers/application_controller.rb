class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :get_job_id
  helper_method :download_link_prefix
  
  
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
end

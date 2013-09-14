class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :get_job_id
  helper_method :download_link_prefix
  helper_method :get_title
  helper_method :pdfbox_jar
  
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
      "/Users/pidezhan/pdfbox/pdfbox-app-1.8.2.jar"
    end
  end
  
  def get_title
    page_title = ""
    site_title = "Stamp PDF, Combine PDF and split PDF online for free with pdfPi.com"
    if controller_name == "home"
      if action_name != "index"
        page_title = action_name.titleize + " PDF Online"
      end
    else
      page_title = action_name.titleize
    end
    page_title.length > 0 ? page_title + " | " + site_title : site_title
  end
end

class FeedbackMailer < ActionMailer::Base
  default from: "non-reply@pdfpi.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.feedback_mailer.feedback.subject
  #
  def feedback(name, email, message, ip)
    @name = name
    @email = email
    @message = message
    @ip = ip

    mail to: "pdfpi.com@gmail.com", subject: "User feedback on pdfpi.com"
  end
  
  def auto_report(job_id)
    @job = Job.find(job_id)
    @uploads = Upload.where(:job_id => @job.session_id)

    mail to: "pdfpi.com@gmail.com", subject: "Auto issue report from pdfpi.com"
  end
  
  def send_link(link, email, expiry_date)
    @link = link
    @expiry_date = expiry_date
    
    mail to: email, subject: "Your download link from pdfPi.com"
  end
end 

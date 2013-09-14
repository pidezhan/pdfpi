class FeedbackMailer < ActionMailer::Base
  default from: "non-reply@pdfpi.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.feedback_mailer.feedback.subject
  #
  def feedback(name, email, message)
    @name = name
    @email = email
    @message = message

    mail to: "pdfpi.com@gmail.com", subject: "User feedback on pdfpi.com"
  end
end 

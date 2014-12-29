class FeedbackController < ApplicationController
  def index

    if request.post? 
      @is_valid_request = verify_recaptcha(message: "Invalid verifcation code")
      if @is_valid_request
        @name = params[:name]
        @email = params[:email]
        @message = params[:msg]
        @ip = request.remote_ip
        FeedbackMailer.feedback(@name, @email, @message, @ip).deliver
        flash.now[:success] = "Your feedback has been sent to us successfully!"
      else
        flash.now[:recaptcha_error] = "Sorry, the verification code was incorrect. Please try again."
        
      end
    end
  end
end

class FeedbackController < ApplicationController
  def index
    if request.post?
      @name = params[:name]
      @email = params[:email]
      @message = params[:msg]
      @ip = request.remote_ip
      FeedbackMailer.feedback(@name, @email, @message, @ip).deliver
      flash.now[:success] = "Your feedback has been sent out successfully!"
    end
  end
end

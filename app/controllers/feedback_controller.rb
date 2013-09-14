class FeedbackController < ApplicationController
  def index
    if request.post?
      @name = params[:name]
      @email = params[:email]
      @message = params[:msg]
      FeedbackMailer.feedback(@name, @email, @message).deliver
      flash.now[:success] = "Your feedback has been sent out successfully!"
    end
  end
end

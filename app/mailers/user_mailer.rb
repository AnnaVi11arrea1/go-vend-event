class UserMailer < ApplicationMailer
  default from: "annavillarreal@govend.ing"
  layout "mailer"

  def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: "Welcome to Govend!", reply_to: "annavillarreal@govend.ing")
    attachments.inline["favicon.png"] = File.read(Rails.root.join("app", "assets", "images", "favicon.png"))
  end

end

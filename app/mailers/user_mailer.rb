class UserMailer < ApplicationMailer
  default from: "annavillarreal@govend.ing"
  layout "mailer"


  def welcome_email(user)
    @user = user
    @url = "http://govend.ing/login"
    mail(to: @user.email, subject: "Welcome to Govend!")
  end
end

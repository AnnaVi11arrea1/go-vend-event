class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: %i[  create edit update destroy ]
  before_action :set_user, only: %i[ edit update destroy ]

  def new
    @user = User.new(user_params)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def show
  end

  def logout
    session.clear
    redirect_to root_path, notice: 'You have been logged out.'
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(@user), notice: "user was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy
    redirect_to new_user_registraiton_path, notice: "User was successfully destroyed."
  end

  private
  # Only allow a list of trusted parameters through.

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :username, :password_confirmation, :first_name, :last_name, :social_media, :about, :photo, :password)
  end

end

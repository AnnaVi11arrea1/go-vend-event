class UsersController < ApplicationController
  # before_action :set_user, only: %i[ index show edit update destroy ]
  before_action :authenticate_user!, only: %i[ show edit create update destroy ]
  before_action :set_user, only: %i[ show edit update destroy ]
  after_action :user_params, only: %i[ edit update]

  def create
    @user = User.new(user_params)
  end

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to edit_user_path(@user), notice: "user was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_url, notice: "User was successfully destroyed."
  end
    
  private

  def set_user
    @user = current_user
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :first_name, :last_name, :social_media, :about, :avatar)
  end
end

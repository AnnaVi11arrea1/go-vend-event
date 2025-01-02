class UsersController < ApplicationController
  # before_action :set_user, only: %i[ index show edit update destroy ]
  before_action :authenticate_user!, only: %i[ show edit update update_photo followers following  ]
  before_action :set_user, only: %i[ show edit update destroy update_photo followers following private  ]
  
  def index
    @users = User.all
  end
  
  def show
    if @user == current_user || !@user.private? || @user.followers.include?(current_user)
    
      @hosted_events = Event.where(:host_id => @user.id)
      @vendor_event = VendorEvent.where(:user_id => @user.id)
    else
      @vendor_event = nil
      @hosted_events = nil
      respond_to do |format|
        format.html { render "users/private", notice: "You are not authorized to view this page." }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @user = User.new(user_params)
  end

  def new
    @user = User.new
  end

  def followers 
  end

  def following
  end

  def feed
    @username = params[:username]
  end

  def discover
  end

  def edit
    @user = current_user
  end

  def edit_photo
    @user = current_user
  end

  def update_photo
    @user = current_user
    if @user.update(user_params)
      redirect_to @user, notice: 'photo was successfully updated.'
    else
      render :edit_user
    end
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
    @user.destroy
    redirect_to root_url, notice: "User was successfully destroyed."
  end

  def logout
    session.clear
    redirect_to root_url, notice: "Logged out!"
  end

  def privacy
    respond_to do |format|
      if true
        format.html { render :privacy_policy }
        format.json { render :privacy_policy }
      else
        format.html { render :privacy_policy }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def private
  @recipient = params[:user]

  end

  private

  def set_user
    @user = User.find(params[:id]) unless params[:username]
  end
    
  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password, :username, :first_name, :last_name, :social_media, :about, :photo, :id)
  end
end

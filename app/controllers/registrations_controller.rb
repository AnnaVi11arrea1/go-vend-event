class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :user_params, only: %i[ show edit update destroy ]


  def new
    @user = User.new
  end

  def create
  before_action :user_params, only: %i[ show edit update destroy ]
  end

  def edit
    @user = current_user
  end

  def show
  
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

  private


  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password, :username, :first_name, :last_name, :social_media, :about)
  end
end

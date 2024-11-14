class UsersController < ApplicationController
  # before_action :set_user, only: %i[ index show edit update destroy ]
  before_action :authenticate_user!, only: %i[ edit update destroy ]
  before_action :set_user, only: %i[ edit update destroy ]

  def create
    @user = User.new(user_params)

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    
  end

  def update
    
  end

  def destroy
    
  end
  private

  def set_user
    @user = User.find(params[:id])
  end
end

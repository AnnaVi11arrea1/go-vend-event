class UsersController < ApplicationController
  # before_action :set_user, only: %i[ index show edit update destroy ]
  before_action :authenticate_user!, only: %i[ show edit update update_photo followers following  ]
  before_action :set_user, only: %i[ feed show edit update destroy update_photo followers following private  ]
  
  def index
    @users = User.all
  end
  
  def show
    if @user == current_user || !@user.private? || @user.followers.include?(current_user)
      begin
        hosted_events_scope = Event.where(host_id: @user.id)
        @hosted_events_total_count = hosted_events_scope.count
        @hosted_search_term = params[:hosted_search].to_s.strip
        @hosted_search_date = params[:hosted_date].to_s.strip

        if @hosted_search_term.present?
          escaped_term = ActiveRecord::Base.sanitize_sql_like(@hosted_search_term.downcase)
          contains_term = "%#{escaped_term}%"
          hosted_events_scope = hosted_events_scope.where(
            "LOWER(events.name) LIKE :term OR LOWER(events.tags) LIKE :term OR LOWER(events.information) LIKE :term",
            term: contains_term
          )

          exact_name = ActiveRecord::Base.connection.quote(escaped_term)
          starts_with_name = ActiveRecord::Base.connection.quote("#{escaped_term}%")
          contains_name = ActiveRecord::Base.connection.quote("%#{escaped_term}%")
          contains_any = ActiveRecord::Base.connection.quote("%#{escaped_term}%")

          hosted_events_scope = hosted_events_scope.order(
            Arel.sql(
              "CASE " \
              "WHEN LOWER(events.name) = #{exact_name} THEN 0 " \
              "WHEN LOWER(events.name) LIKE #{starts_with_name} THEN 1 " \
              "WHEN LOWER(events.name) LIKE #{contains_name} THEN 2 " \
              "WHEN LOWER(events.tags) LIKE #{contains_any} THEN 3 " \
              "WHEN LOWER(events.information) LIKE #{contains_any} THEN 4 " \
              "ELSE 5 END"
            ),
            started_at: :asc
          )
        else
          hosted_events_scope = hosted_events_scope.order(started_at: :asc)
        end

        if @hosted_search_date.present?
          parsed_date = Date.parse(@hosted_search_date)
          hosted_events_scope = hosted_events_scope.where(started_at: parsed_date)
        end

        @hosted_events = hosted_events_scope.page(params[:hosted_events_page]).per(10)
        @show_hosted_search = @hosted_events_total_count > 10 || @hosted_search_term.present? || @hosted_search_date.present?
        @hosted_events_query_params = request.query_parameters.except("hosted_events_page")
        @vendor_event = VendorEvent.where(:user_id => @user.id)
      rescue ArgumentError
        hosted_events_scope = Event.where(host_id: @user.id).order(started_at: :asc)
        @hosted_events = hosted_events_scope.page(params[:hosted_events_page]).per(10)
        @hosted_events_total_count = hosted_events_scope.count
        @show_hosted_search = @hosted_events_total_count > 10 || @hosted_search_term.present?
        @hosted_events_query_params = request.query_parameters.except("hosted_events_page", "hosted_date")
        @vendor_event = VendorEvent.where(:user_id => @user.id)
        flash.now[:alert] = "Please enter a valid date in YYYY-MM-DD format."
      end
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
    if @user.save
      UserMailer.welcome_email(@user).deliver_now
    end
  end

  def new
    @user = User.new
  end

  def followers 
  end

  def following
  end

  def feed
    @user = current_user
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
    @user = User.find_by(id: params[:id])
  end
    
  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password, :username, :first_name, :last_name, :social_media, :about, :photo, :id, :sender_id, :user_id, :recipient_id, :status, :private, :admin)
  end
end

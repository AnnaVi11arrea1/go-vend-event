class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[show edit update destroy ]

  # GET /follow_requests or /follow_requests.json
  def index
    @follow_requests = FollowRequest.all.where(recipient_id: current_user.id)
    @pending_requests = current_user.received_follow_requests.pending
    @accepted_requests = current_user.received_follow_requests.accepted
  end

  # GET /follow_requests/1 or /follow_requests/1.json
  def show
  end

  # GET /follow_requests/new
  def new
    @user = User.find(params[:user_id])
    @follow_request = FollowRequest.new
  end

  # GET /follow_requests/1/edit
  def edit
  end

  # POST /follow_requests or /follow_requests.json
  def create
    @follow_request = FollowRequest.new(follow_request_params)
    @user = User.find(params[:user_id])

    @follow_request.save

    respond_to do |format|

        format.html { redirect_to user_follow_requests_path(@follow_request.recipient.id), notice: "Follow request was successfully created." }
        format.json { render :show, status: :created, location: @follow_request }

    end
  end

  # PATCH/PUT /follow_requests/1 or /follow_requests/1.json
  def update
    respond_to do |format|
      if @follow_request.update(follow_request_params)
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully updated." }
        format.json { render :show, status: :ok, location: @follow_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follow_requests/1 or /follow_requests/1.json
  def destroy
    @follow_request.destroy!
    respond_to do |format|
      format.html { redirect_to follow_requests_path, status: :see_other, notice: "Follow request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def accept
    @follow_request = FollowRequest.find(params[:id])
    if @follow_request.update(status: :accepted)
      redirect_to user_path(@follow_request.sender), notice: 'Follow request accepted.'
    else
      redirect_to follow_requests_path, alert: 'Unable to accept follow request.'
    end
  end
  
  def reject
    @follow_request = FollowRequest.find(params[:id])
    if @follow_request.update(status: :rejected)
      redirect_to follow_requests_path, notice: 'Follow request rejected.'
    else
      redirect_to follow_requests_path, alert: 'Unable to reject follow request.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_follow_request
      @follow_request = FollowRequest.find_by(id: params[:id])
      unless @follow_request
        redirect_to follow_requests_path, alert: "Follow request not found."
      end
    end

    # Only allow a list of trusted parameters through.
    def follow_request_params
      if params[:follow_request].present?
        params.require(:follow_request).permit(:recipient_id, :sender_id)
      else
        { recipient_id: params[:user_id], sender_id: current_user.id }
      end
    end
end

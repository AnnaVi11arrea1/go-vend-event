class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[ show edit update destroy ]

  # GET /follow_requests or /follow_requests.json
  def index
    @follow_requests = FollowRequest.all.where(recipient_id: current_user.id)
  end

  # GET /follow_requests/1 or /follow_requests/1.json
  def show
    @follow_requests = FollowRequest.where(recipient_id: current_user.id)
  end

  # GET /follow_requests/new
  def new
    Rails.logger.debug "Recipient ID: #{params[:recipient_id]}"
    @follow_request = FollowRequest.new   
    @recipient_id = params[:recipient_id]
  end

  # GET /follow_requests/1/edit
  def edit
  end

  # POST /follow_requests or /follow_requests.json
  def create
    @follow_request = FollowRequest.new(follow_request_params)
    @follow_request.sender_id = current_user.id # Ensure sender is the current user

    respond_to do |format|
      if @follow_request.save
        format.html { redirect_to follow_requests_path(@follow_request), notice: "Follow request was successfully created." }
        format.json { render :show, status: :created, location: @follow_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
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
      params.require(:follow_request).permit(:recipient_id, :sender_id, :status)
    end
end

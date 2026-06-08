class FollowRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_follow_request, only: %i[ show edit update destroy accept reject ]
  before_action :set_recipient_from_params, only: %i[ new create ]
  before_action :authorize_access!, only: %i[ show edit update destroy ]
  before_action :authorize_recipient_action!, only: %i[ accept reject ]


  # GET /follow_requests or /follow_requests.json
  def index
    base_received = FollowRequest.includes(:sender).where(recipient_id: current_user.id).order(created_at: :desc)
    base_sent = FollowRequest.includes(:recipient).where(sender_id: current_user.id).order(created_at: :desc)

    @pending_received_follow_requests = base_received.pending
    @pending_sent_follow_requests = base_sent.pending
    @received_follow_requests = base_received
    @sent_follow_requests = base_sent
  end

  # GET /follow_requests/1 or /follow_requests/1.json
  def show
  end

  # GET /follow_requests/new
  def new
    @follow_request = FollowRequest.new
    @follow_request.sender = current_user
    @follow_request.recipient = @recipient
  end

  # GET /follow_requests/1/edit
  def edit
  end

  # POST /follow_requests or /follow_requests.json
  def create
    if @recipient.nil?
      redirect_back fallback_location: users_path, alert: "Recipient not found." and return
    end

    follow_request = FollowRequest.find_or_initialize_by(sender: current_user, recipient: @recipient)

    if follow_request.accepted?
      redirect_to user_path(@recipient), notice: "You are already following #{@recipient.username}."
    elsif follow_request.pending?
      redirect_to user_path(@recipient), notice: "Follow request already sent."
    else
      follow_request.status = :pending
      follow_request.admin_response = nil if follow_request.respond_to?(:admin_response)

      if follow_request.save
        redirect_to user_path(@recipient), notice: "Follow request sent."
      else
        redirect_to user_path(@recipient), alert: follow_request.errors.full_messages.to_sentence
      end
    end
  end

  # PATCH/PUT /follow_requests/1 or /follow_requests/1.json
  def update
    respond_to do |format|
      if @follow_request.update(follow_request_params)
        format.html { redirect_back fallback_location: follow_requests_path, notice: "Follow request was successfully updated." }
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
      format.html { redirect_to follow_requests_path, status: :see_other, notice: "Follow request was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def accept
    if @follow_request.update(status: :accepted)
      redirect_to follow_requests_path, notice: "Follow request accepted."
    else
      redirect_to follow_requests_path, alert: "Unable to accept follow request."
    end
  end

  def reject
    if @follow_request.update(status: :rejected)
      redirect_to follow_requests_path, notice: "Follow request rejected."
    else
      redirect_to follow_requests_path, alert: "Unable to reject follow request."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_follow_request
    @follow_request = FollowRequest.find(params[:id])
  end

  def set_recipient_from_params
    recipient_id = params[:user_id] || params.dig(:follow_request, :recipient_id)
    @recipient = User.find_by(id: recipient_id)
  end

  def authorize_access!
    return if @follow_request.sender_id == current_user.id || @follow_request.recipient_id == current_user.id

    redirect_to follow_requests_path, alert: "You are not authorized to access this follow request."
  end

  def authorize_recipient_action!
    return if @follow_request.recipient_id == current_user.id

    redirect_to follow_requests_path, alert: "Only the recipient can update this request."
  end

  # Only allow a list of trusted parameters through.
  def follow_request_params
    permitted = [:status]

    if action_name.in?(%w[new create])
      permitted += [:recipient_id]
    end

    params.require(:follow_request).permit(permitted)
  end

end

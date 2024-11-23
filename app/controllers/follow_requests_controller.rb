class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[ show edit update destroy ]


  # GET /follow_requests or /follow_requests.json
  def index
    @follow_requests = FollowRequest.all
  end

  # GET /follow_requests/1 or /follow_requests/1.json
  def show
  end

  # GET /follow_requests/new
  def new
    @follow_request = FollowRequest.new
    @sender = User.where(:id => :sender_id)
    @reciever = User.where(:id => :reciever_id)
   
  end

  # GET /follow_requests/1/edit
  def edit
  end

  # POST /follow_requests or /follow_requests.json
  def create
    @follow_request = FollowRequest.new(follow_request_params)

    respond_to do |format|
      if @follow_request.save
        format.html { redirect_to follow_reques_url(@follow_request), notice: "Follow request was successfully created." }
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
        format.html { redirect_to follow_request_url(@follow_request), notice: "Follow request was successfully updated." }
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
      @follow_request = FollowRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def follow_request_params
      params.require(:follow_request).permit(:recipient_id, :sender_id, :status)
    end
end

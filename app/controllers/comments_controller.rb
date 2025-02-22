class CommentsController < ApplicationController
  before_action :set_event
  before_action :set_comment, only: %i[ edit update destroy ]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show

  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # POST /comments or /comments.json
  def create
    @event = Event.find_by(id: params[:event_id])

    unless @event
      redirect_to events_path, alert: "Event not found."
      return
    end
  
    @comment = Comment.new(comment_params)
    @comments = @event.comments.all
    @comment.author = current_user # Ensure author is assigned

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @event, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update

    if @comment.update(comment_params)
    respond_to do |format|
        format.html { redirect_to @event, notice: 'Comment was successfully updated.' }
        format.js
    end
    else
      render :edit
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    
    if @comment.author == current_user
      @comment.destroy!
      redirect_to @comment.event, notice: "Comment was successfully destroyed."
    else
      redirect_to @comment.event, alert: "You are not authorized to delete this comment."
    end
  end

  private
    def set_comment
      @comment = @event.comments.find(params[:id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    def comment_params
      params.require(:comment).permit(:body)
    end
end

class NotesController < ApplicationController
  before_action :set_vendor_event
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def create
    @note = @vendor_event.notes.build(note_params)
    @note.user = current_user
    if @note.save
      redirect_to @vendor_event, notice: 'Note was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to @vendor_event, notice: 'Note was successfully updated.'
    else
      render :edit
    end
  end

    def destroy
      @note.destroy
      redirect_to @vendor_event, notice: 'Note was successfully destroyed.'
    end

    private

    def set_vendor_event
      @vendor_event = VendorEvent.find(params[:vendor_event_id])
    end

    def set_note
      @note = @vendor_event.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:content)
    end

    def authorize_user
      redirect_to @event, alert: "Not authorized!" unless @note.user == current_user
    end
end

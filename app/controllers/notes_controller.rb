class NotesController < ApplicationController
  before_action :set_contact
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # GET /notes
  # GET /notes.json
  def index
    @notes = @contact.notes
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = @contact.notes.new(note_params)

    respond_to do |format|
      if @note.save
        format.html { redirect_to @contact, notice: 'Note was successfully created.' }
        format.json { render action: 'show', status: :created, location: @note }
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @contact, notice: 'Note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to @contact }
      format.json { head :no_content }
    end
  end

  private
    
    def set_contact
      @contact = current_user.contacts.find(params[:contact_id])
    end
    
    def set_note
      @note = @contact.notes.find(params[:id])
      redirect_to @contact unless @note
    end

    def note_params
      params.require(:note).permit(:contact_id, :description, :date)
    end
end

class ContactsController < ApplicationController
  before_action :set_fields
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    search = []
    search = params[:search].map { |k, v| v } if params[:search]
    params[:order] ||= "name"
    params[:direction] ||= "asc"
    
    @contacts = current_user.contacts.filter(search, params[:q], params[:order], params[:direction], params[:data_type])
    @pending = @contacts.pending
    
    respond_to do |format|
      if @contacts.empty?
        format.html { redirect_to new_contact_path }
      else
        format.html
      end
      
      format.json
      format.js
    end
  end
  
  # GET /pending
  # GET /pending.json
  def pending
    @contacts = current_user.contacts.pending
    
    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @user = current_user
    
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to fields_path, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to contacts_path, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = current_user.contacts.find(params[:id])
    end
    
    def set_fields
      @fields = current_user.fields
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :overwrite, data: current_user.fields.pluck(:permalink))
    end
    
    def user_params
      params.require(:user).permit(:file, :blob)
    end
end

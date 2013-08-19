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
    
    @contacts = current_user.contacts.filter(search, params[:q], params[:order], params[:direction], params[:data_type]).page(params[:page]).per_page(50)
    @pending_count = current_user.contacts.pending.count
    
    respond_to do |format|
      format.html
      format.json
      format.csv { send_data @contacts.to_csv(current_user.id) }
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
    @tasks = @contact.tasks
  end

  # GET /contacts/new
  def new
    @user = current_user
    @contact = Contact.new
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @user = current_user
    @contact = @user.contacts.new(contact_params)

    respond_to do |format|
      if @contact.save
        @user.set_step && @user.save if @user.step < 3
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /multicreate
  # POST /multicreate.json
  def multicreate
    @user = current_user
    @contact = Contact.new
    
    if params[:delete_pending]
      @user.import_progress = 100
      @user.blob = nil
      @user.file.clear
      @user.save
      redirect = new_contact_path
    else
      @user.create_headers if @user.update_attributes(user_params)
      redirect = fields_path
    end
    
    respond_to do |format|
      if @user.errors.empty?
        format.html { redirect_to redirect, notice: 'Contact was successfully created.' }
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
        @pending_count = current_user.contacts.pending.count
        format.html { redirect_to contacts_path, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        format.js
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
      params.require(:contact).permit(:name, :overwrite, :use_pending, data: current_user.fields.pluck(:permalink))
    end
    
    def user_params
      params.require(:user).permit(:file, :blob, :overwrite)
    end
end

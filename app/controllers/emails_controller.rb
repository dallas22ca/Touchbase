class EmailsController < ApplicationController
  before_action :set_email, only: [:show]

  # GET /emails
  # GET /emails.json
  def index
    @emails = current_user.emails
  end

  # GET /emails/1
  # GET /emails/1.json
  def show
  end

  # GET /emails/new
  def new
    @email = Email.new
  end

  # POST /emails
  # POST /emails.json
  def create
    @email = current_user.emails.new(email_params)
    parse_criteria(@email)

    respond_to do |format|
      if @email.save
        format.html { redirect_to contacts_path, notice: 'Email is sending.' }
        format.json { render action: 'show', status: :created, location: @email }
      else
        format.html { render action: 'new' }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email
      @email = current_user.emails.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:subject, :plain)
    end
end

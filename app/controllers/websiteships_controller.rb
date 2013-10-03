class WebsiteshipsController < ApplicationController
  before_action :set_websiteship, only: [:show, :edit, :update, :destroy]

  # GET /websiteships
  # GET /websiteships.json
  def index
    @websiteships = Websiteship.all
  end

  # GET /websiteships/1
  # GET /websiteships/1.json
  def show
  end

  # GET /websiteships/new
  def new
    @websiteship = Websiteship.new
  end

  # GET /websiteships/1/edit
  def edit
  end

  # POST /websiteships
  # POST /websiteships.json
  def create
    @websiteship = Websiteship.new(websiteship_params)

    respond_to do |format|
      if @websiteship.save
        format.html { redirect_to @websiteship, notice: 'Websiteship was successfully created.' }
        format.json { render action: 'show', status: :created, location: @websiteship }
      else
        format.html { render action: 'new' }
        format.json { render json: @websiteship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /websiteships/1
  # PATCH/PUT /websiteships/1.json
  def update
    respond_to do |format|
      if @websiteship.update(websiteship_params)
        format.html { redirect_to @websiteship, notice: 'Websiteship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @websiteship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /websiteships/1
  # DELETE /websiteships/1.json
  def destroy
    @websiteship.destroy
    respond_to do |format|
      format.html { redirect_to websiteships_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_websiteship
      @websiteship = Websiteship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def websiteship_params
      params.require(:websiteship).permit(:website_id, :user_id)
    end
end

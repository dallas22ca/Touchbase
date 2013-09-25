class PagesController < ApplicationController
  before_action :set_website
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    @pages = @website.pages
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @path = request.path

    if user_signed_in? && params[:layout]
      layout = params[:layout].split(".")
      @document = Document.where(name: layout.first, extension: layout.last).first
      @page.layout = @document if @document
    end
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @website.pages.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to public_page_url(@page.permalink, subdomain: @website.permalink), notice: 'Page was successfully created.' }
        format.json { render action: 'show', status: :created, location: @page }
      else
        format.html { render action: 'new' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to public_page_url(@page.permalink, subdomain: @website.permalink), notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy unless @page == @website.default_page
    respond_to do |format|
      format.html { redirect_to root_url(subdomain: @website.permalink) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      if params[:permalink]
        @page = @website.pages.where(permalink: params[:permalink]).first
        redirect_to root_path if @page == @website.default_page
      elsif ["edit", "update", "destroy"].include? action_name
        @page = @website.pages.find(params[:id])
      else
        @page = @website.default_page
      end
      
      render text: "404: no page here." if !@page && action_name != "destroy"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:website_id, :title, :permalink, :document_id, :parent_id)
    end
    
    def set_website
      if request.subdomain == "www"
        @website = Website.find(params[:website_id])
      else
        @website = Website.where(permalink: request.subdomain).first
      end

      render text: "No account setup on this subdomain" unless @website
    end
end

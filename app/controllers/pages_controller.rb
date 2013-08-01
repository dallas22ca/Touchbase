class PagesController < ApplicationController
  def show
    permalink = params[:permalink]
    permalink ||= "welcome"
    render "pages/templates/#{permalink}"
  end
end

class PagesController < ApplicationController
  def show
    permalink = params[:permalink]
    permalink ||= "learn"
    render permalink
  end
end

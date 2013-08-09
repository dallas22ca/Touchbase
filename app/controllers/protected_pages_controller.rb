class ProtectedPagesController < ApplicationController
  def show
    permalink = params[:permalink]
    permalink ||= "dashboard"
    render permalink
  end
end
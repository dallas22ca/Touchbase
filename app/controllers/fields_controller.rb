class FieldsController < ApplicationController
  before_action :set_fields 
  
  def index
    current_user.fields.new(permalink: "birthday", title: "Birthday", data_type: "datetime") if @fields.where("data_type = ?", "datetime").empty?
  end
  
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(user_params)
        if @user.contacts.any?
          redirect = contacts_path
        else
          redirect = followups_path
        end
        
        format.html { redirect_to redirect, notice: 'Fields were successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
private
  
  def set_fields
    @fields = current_user.fields
  end
  
  def user_params
    params.require(:user).permit(:upload, fields_attributes: [:id, :title, :permalink, :data_type, :ordinal, :show, :_destroy])
  end
  
end

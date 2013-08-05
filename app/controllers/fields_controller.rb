class FieldsController < ApplicationController
  before_action :set_fields 
  
  def index
    if current_user.step == 1
      redirect_to new_contact_path
    else
      if current_user.blob.blank?
        
      else
      end
    end
  end
  
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to contacts_path, notice: 'Fields were successfully updated.' }
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
    params.require(:user).permit(:upload, fields_attributes: [:id, :title, :permalink, :data_type, :_destroy])
  end
  
end

class FollowupsController < ApplicationController
  before_action :set_followups 
  
  def index
  end
  
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to tasks_path, notice: 'Followups were successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
private
  
  def set_followups
    @followups = current_user.followups
  end
  
  def user_params
    params.require(:user).permit(followups_attributes: [:id, :description, :offset, :field_id, :data_type, :_destroy])
  end
  
end

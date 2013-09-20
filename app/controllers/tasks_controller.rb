class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    @now = Time.zone.now
    params[:start] ||= Time.zone.now.strftime("%m-%d-%y")
    @start = Chronic.parse(params[:start]).beginning_of_day if params[:start]
    @start ||= Time.zone.now.beginning_of_day
    @finish = Chronic.parse(params[:finish]).end_of_day if params[:finish]
    @finish ? @date = "#{@start.strftime("%B %-d")} - #{@finish.strftime("%B %-d, %Y")}" : @date = @start.strftime("%A, %b %-d")
    @finish ||= @start.end_of_day
    @next = @start + 1.day
    @prev = @finish - 1.day
    @tasks = current_user.tasks_for(@start, @finish)
    @today = (@start < @now && @now < @finish)
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = current_user.tasks.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path, notice: 'Task was successfully created.' }
        format.json { render action: 'show', status: :created, location: @task }
      else
        format.html { render action: 'new' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
        format.js { render nothing: true }
      else
        format.html { render action: 'edit' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:followup_id, :date, :content, :complete)
    end
end

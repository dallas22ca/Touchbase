require_relative "../test_helper"

describe Followup do
  fixtures :all
  
  before :each do
    ImportWorker.jobs.clear
    Task.destroy_all
  end
  
  it "ALL TEST FIXTURES SHOULD FAIL IN JANUARY" do
    Time.now.month.should_not == 1
  end
  
  it "adds name to the description if needed" do
    joe = users(:joe)
    followup = joe.followups.create!(
      description: "Send a birthday card",
      field: fields(:birthday)
    )
    followup.description.should include("{{name}}")
  end
  
  it "substitutes birthday shortcode" do
    fields(:birthday).substitute_data(Time.now).should == Time.now.strftime("%B %-d")
  end
  
  it "returns user's tasks for today" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    joe.tasks_for(Time.now).count.should == 1
    joe.tasks.update_all complete: true
    joe.tasks_for(Time.now).count.should == 0
  end
  
  it "removes any future tasks if followup is deleted" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    Task.count.should == 1
    Followup.destroy_all
    Task.count.should == 0
  end
  
  it "removes any future tasks if field is deleted" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    Task.count.should == 1
    Field.destroy_all
    Task.count.should == 0
  end
  
  it "adds tasks to new contacts" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
    contact = joe.save_contact name: Faker::Name.name, data: { birthday: 1.week.from_now - 55.years }
    ImportWorker.drain
    followup.tasks.count.should == 2
  end
  
  it "renaming a field prepares contacts"
  
  it "every 3 weeks starting now"
  it "every 3 weeks starting on their birthday"
  it "on birthday"
  it "3 weeks after birthday"
  it "3 weeks before birthday"
  
  # it "doesn't create duplicate tasks"
  # it "update contacts when field is changed"
  # it "update future tasks if followup is changed"
end
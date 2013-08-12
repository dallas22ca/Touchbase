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
  
  it "create tasks with a field" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
    joe.tasks.count.should == 1
    followup.tasks.first.content.should include(contacts(:birthday_in_a_week).name)
  end
  
  it "doens't create duplicate tasks" do
    followup = followups(:two_weeks_before_birthday)
    2.times { followup.create_tasks }
    followup.create_tasks(3.days.from_now)
    followup.tasks.count.should == 1
  end
  
  it "creates tasks with a field" do
    joe = users(:joe)
    followup = followups(:two_weeks_after_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
    joe.tasks.count.should == 1
    followup.tasks.first.content.should include(contacts(:birthday_a_week_ago).name)
    followup.tasks.first.content.should include(contacts(:birthday_a_week_ago).data["birthday"].in_time_zone.strftime("%B %d"))
  end
  
  it "returns users tasks for today" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    joe.tasks_for(Time.now).count.should == 1
  end
  
  it "returns users tasks for today" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    joe.tasks.update_all complete: true
    joe.tasks_for(Time.now).count.should == 0
  end
  
  it "updates any future tasks if field is changed" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    joe.tasks_for(Time.now).count.should == 1
    followup.update_attributes! offset: 3.days * -1, description: "Give {{name}} a handshake"
    ImportWorker.drain
    joe.tasks.first.content.should include("handshake")
    joe.tasks_for(Time.now).count.should == 0
    joe.tasks_for(4.days.from_now).count.should == 1
  end
  
  it "removes any future tasks if field is deleted" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    Task.count.should == 1
    followup.destroy!
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
end
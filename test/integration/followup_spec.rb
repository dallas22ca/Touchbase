require_relative "../test_helper"

describe Followup do
  fixtures :all
  
  it "ALL FOLLOWUPS SHOULD FAIL IN JANUARY" do
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
  
  it "generates tasks with a field" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.generate_tasks
    followup.tasks.count.should == 1
    joe.tasks.count.should == 1
    followup.tasks.first.content.should include(contacts(:birthday_in_a_week).name)
  end
  
  it "doens't generate duplicate tasks" do
    followup = followups(:two_weeks_before_birthday)
    2.times { followup.generate_tasks }
    followup.generate_tasks(3.days.from_now)
    followup.tasks.count.should == 1
  end
  
  it "generates tasks with a field" do
    joe = users(:joe)
    followup = followups(:two_weeks_after_birthday)
    followup.generate_tasks
    followup.tasks.count.should == 2
    joe.tasks.count.should == 2
    followup.tasks.first.content.should include(contacts(:birthday_5_weeks_ago).name)
  end
  
  it "returns users tasks for today" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.generate_tasks
    joe.tasks_for(Time.now).count.should == 0
  end
  
  it "updates any future tasks if field is changed" do
    
  end
  
  it "removes any future tasks if field is deleted" do
  end
end
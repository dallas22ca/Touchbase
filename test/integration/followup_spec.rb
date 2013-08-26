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
    followup.description.should include("{{contact.name}}")
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
    contact = joe.save_contact name: Faker::Name.name, birthday: 1.week.from_now - 55.years
    ImportWorker.drain
    followup.tasks.count.should == 2
  end
  
  it "every 3 weeks starting now" do
    joe = users(:joe)
    followup = followups(:every_three_weeks)
    followup.create_tasks false, 30.days + 3.weeks - 1.day
    followup.tasks.count.should == 8
  end
  
  it "every 5 weeks starting now" do
    joe = users(:joe)
    followup = followups(:every_five_weeks)
    followup.create_tasks false, 30.days + 5.weeks - 1.day
    followup.tasks.count.should == 4
  end
  
  it "every 3 weeks starting on their birthday" do
    joe = users(:joe)
    followup = followups(:every_three_weeks_starting_on_birthday)
    followup.create_tasks
    followup.tasks.count.should == 6
  end
  
  it "every 5 weeks starting on their birthday" do
    joe = users(:joe)
    followup = followups(:every_five_weeks_starting_on_birthday)
    followup.create_tasks
    followup.tasks.count.should == 4
  end
  
  it "on birthday" do
    joe = users(:joe)
    followup = followups(:on_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
  end
  
  it "2 weeks after birthday" do
    joe = users(:joe)
    followup = followups(:two_weeks_after_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
  end
  
  it "2 weeks before birthday" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    followup.tasks.count.should == 1
  end
  
  it "creates tasks for only 1 contact" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    
    Task.destroy_all
    contact = contacts(:birthday_in_a_week)
    followup.create_tasks(contact.id)
    followup.tasks.count.should == 1
    
    Task.destroy_all
    contact = contacts(:birthday_a_week_ago)
    followup.create_tasks(contact.id)
    followup.tasks.count.should == 0
  end
  
  it "doesn't create duplicate tasks" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    followup.tasks.first.update_attributes complete: true
    2.times.map { followup.create_tasks }
    followup.tasks.count.should == 1
  end
  
  it "updates future tasks if followup is changed" do
    joe = users(:joe)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    task_content = followup.tasks.first.content
    followup.update_attributes description: "Say Wahoo"
    ImportWorker.drain
    followup.tasks.first.content.should include("Say Wahoo")
  end
  
  it "updates followups for contact if contact is changed" do
    ImportWorker.jobs.clear
    joe = users(:joe)
    c = contacts(:birthday_in_a_week)
    followup = followups(:two_weeks_before_birthday)
    followup.create_tasks
    c.update_attributes! name: "Super Man"
    ImportWorker.drain
    followup.tasks.first.reload.content_with_links.should include(c.name)
  end
  
  it "creates followups with criteria (awesome: true)" do
    joe = users(:joe)
    c = contacts(:birthday_a_week_ago)
    followup = followups(:awesome)
    p followup.remind_every?
    followup.create_tasks
    followup.contacts.count.should == 1
    followup.tasks.first.reload.content_with_links.should include(c.name)
  end
  
  it "creates followups with criteria (awesome: false)" do
    joe = users(:joe)
    followup = followups(:not_awesome)
    followup.create_tasks
    followup.contacts.count.should == 0
  end
end
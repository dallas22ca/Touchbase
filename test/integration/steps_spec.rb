require_relative "../test_helper"

describe "Steps" do
  fixtures :all
  
  it "Start" do
    vlad = users(:vlad)
    login_as vlad
    vlad.update_column :step, 1
    visit fields_path
    page.current_path.should_not == fields_path
    visit new_contact_path
    page.current_path.should == new_contact_path
  end
  
  it !2 do
    vlad = users(:vlad)
    login_as vlad
    vlad.update_attributes blob: "Name, Email\nSuper Name, email@test.com"
    vlad.step.should == 3
  end
  
  it 3 do
    vlad = users(:vlad)
    login_as vlad
    vlad.update_column :step, 3
    visit fields_path
    page.current_path.should_not == fields_path
    vlad.update_column :step, 3
    visit new_contact_path
    page.current_path.should == new_contact_path
  end
  
  it 4 do
    vlad = users(:vlad)
    login_as vlad
    vlad.update_column :step, 4
    visit followups_path
    page.current_path.should_not == followups_path
    vlad.update_column :step, 4    
    visit fields_path
    page.current_path.should == fields_path
  end
  
  it "Finished" do
    vlad = users(:vlad)
    vlad.update_column :step, 5
    login_as vlad
    visit tasks_path
    page.current_path.should == tasks_path
  end
end

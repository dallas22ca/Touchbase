require_relative "../test_helper"

describe User do
  fixtures :all
  
  before :each do
    Contact.destroy_all
    ImportWorker.jobs.clear
  end
  
  it "can upload file with header" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withheaders.csv"
    
    login_as joe
    visit new_contact_path
    attach_file :user_file, path
    click_button "Add Contacts"
    joe.contacts.count.should == 0
    page.should have_content "Fields" # Fields#index
    click_button "Save Fields and Continue to Upload File"
    joe.contacts.count.should == 0
    ImportWorker.drain
    joe.contacts.count.should == 4
    visit contacts_path
    page.should have_content joe.contacts.first.name
  end
  
  it "can't upload a nonheader file" do
    joe = users(:joe)
    path = "#{Rails.root}/test/assets/4withoutheaders.csv"
    
    login_as joe
    visit new_contact_path
    attach_file :user_file, path
    click_button "Add Contacts"
    joe.contacts.count.should == 0
    page.should have_content "header"
  end
  
  it "can input text with header" do
    joe = users(:joe)
    text = "Name, Email, Hobbies\nDallas Read, dallas@touchbasenow.com, Futbol"
    
    login_as joe
    visit new_contact_path
    fill_in :user_blob, with: text
    click_button "Add Contacts"
    joe.contacts.count.should == 0
    page.should have_content "Fields"
    click_button "Save Fields and Continue to Upload File"
    joe.contacts.count.should == 0
    ImportWorker.drain
    joe.contacts.count.should == 1
    visit contacts_path
    page.should have_content joe.contacts.first.name
  end
  
  it "can't input nonheader text" do
    joe = users(:joe)
    text = "Dallas Read, dallas@touchbasenow.com, Futbol"
    
    login_as joe
    visit new_contact_path
    fill_in :user_blob, with: text
    click_button "Add Contacts"
    joe.contacts.count.should == 0
    page.should have_content "header"
  end
end
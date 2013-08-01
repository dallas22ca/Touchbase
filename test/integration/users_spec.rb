require_relative "../test_helper"

describe User do
  fixtures :all
  
  it "can sign up when visiting the root path" do
    visit root_url
    page.should have_content "Sign up"
  end
  
  it "is asked to upload contacts if none exists" do
    joe = users(:joe)
    login_as joe
    joe.contacts.count.should == 0
    visit contacts_path
    page.should have_content "Upload"
  end
  
  it "sees his contacts if he has some" do
    joe = users(:joe)
    login_as joe
    
    2.times do
      @c = contacts(:basic)
      joe.contacts.push @c
    end
    
    visit contacts_path
    page.should have_content @c.name
  end
end
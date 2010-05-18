Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  unless login.blank?
    user = Factory.create(:user, :email => login, :password => password)
    if 0 == login.index('admin')
      user.add_role! 'admin'
    end
    visit login_url
    fill_in "user_session[login]", :with => login
    fill_in "user_session[password]", :with => password
    click_button "Log in"
  end
end
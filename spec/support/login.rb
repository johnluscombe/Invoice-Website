def login(user, options = {})
#    if example.metadata[:type] == :request
  if options[:avoid_capybara]
    post logins_path, username: user.name, password: user.password
  else
    visit login_path
    fill_in 'Username', with: user.name
    fill_in 'Password', with: user.password
    click_button 'Log In'
  end
end
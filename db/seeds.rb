# frozen_string_literal: true

test_user = User.find_or_initialize_by(email: "test@wantboard.dev")
if test_user.new_record?
  test_user.assign_attributes(
    name: "Test User",
    password: "test123",
    location: "Test City"
  )
  test_user.save!
  puts "Created test user test@wantboard.dev / test123"
else
  puts "Test user already exists"
end

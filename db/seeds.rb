# frozen_string_literal: true

test_user = User.find_or_initialize_by(email: "test@wantboard.dev")
if test_user.new_record?
  test_user.assign_attributes(
    name: "Test User",
    password: "test",
    location: "Test City"
  )
  test_user.save!
  puts "Created test user test@wantboard.dev / test"
else
  puts "Test user already exists"
end

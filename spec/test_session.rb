TEST_USERNAME = "testname"
TEST_EMAIL = "t@test.com"
ENDPOINT = "/login/submit"

def create_user
  User.new(
    google_id: TEST_G_ID,
    username: TEST_USERNAME,
    email: TEST_EMAIL
  ).save!
end

def log_in
  visit ENDPOINT
end

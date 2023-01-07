TEST_USERNAME = "testname"
TEST_EMAIL = "t@test.com"
ENDPOINT = "/login/submit"

def log_in
  User.new(
    google_id: TEST_G_ID,
    username: TEST_USERNAME,
    email: TEST_EMAIL
  ).save
  visit ENDPOINT
end

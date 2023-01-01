TEST_G_ID = "1234567890"
TEST_EMAIL = "test@test.com"

module GoogleSignIn
  class Identity
    attr_accessor :user_id, :email_address

    def initialize(_)
      @user_id = TEST_G_ID
      @email_address = TEST_EMAIL
    end
  end
end

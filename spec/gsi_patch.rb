TEST_G_ID = "1234567890"
TOKEN_EMAIL = "test@test.com"

module GoogleSignIn
  class Identity
    attr_accessor :user_id, :email_address

    def initialize(_)
      @user_id = TEST_G_ID
      @email_address = TOKEN_EMAIL
    end
  end
end

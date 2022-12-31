module UsersHelper
  def logged_in?
    @current_user.present?
  end
end

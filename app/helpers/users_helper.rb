module UsersHelper
  def logged_in?
    @current_user.present?
  end

  def logged_out?
    !logged_in?
  end
end

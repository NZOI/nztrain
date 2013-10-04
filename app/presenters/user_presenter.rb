class UserPresenter < BasePresenter
  presents :user
  delegate :username, :name, :email, to: :user

  def avatar
    h.tag :img, :src => user.avatar_url
  end

end

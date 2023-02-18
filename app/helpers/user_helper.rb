module UserHelper
  def avatar(user)
    image_tag user.avatar_url
  end
end

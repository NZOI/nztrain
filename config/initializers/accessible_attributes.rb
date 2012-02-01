class ActiveRecord::Base
  attr_accessible :session_id

  # allows dynamically adding accessible attributes
  attr_accessor :accessible
  private :mass_assignment_authorizer
  # https://gist.github.com/919326
  # based on Railscast 237, http://railscasts.com/episodes/237-dynamic-attr-accessible
  def mass_assignment_authorizer
    if accessible == :all
      # original hack, doesn't work with AR attribute type
      # self.class.protected_attributes
      
      # This hack should work as well with AR attribute type
      ActiveModel::MassAssignmentSecurity::BlackList.new {:id}
    else
      super + (accessible || [])
    end
  end
end


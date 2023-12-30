class Group < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, class_name: GroupMembership, dependent: :destroy
  has_many :members, through: :memberships
  has_many :problem_set_associations, -> { includes(:problem_set).order("COALESCE(group_problem_sets.name,problem_sets.name)").references(:group_problem_sets, :problem_sets) }, class_name: GroupProblemSet, dependent: :destroy, inverse_of: :group
  has_many :problem_sets, through: :problem_set_associations
  has_many :contest_associations, class_name: GroupContest, inverse_of: :group, dependent: :destroy
  has_many :contests, through: :contest_associations

  belongs_to :owner, :class_name => :User

  has_many :join_requests, -> { where(:subject_type => 'User', :verb => 'join') }, :class_name => :Request, :as => :target
  #, -> { where :subject_type => :users, :verb => :join }
  #has_many :applicants, :through => :applications, :source => :subject, :source_type => 'User'
  #def applicants
  #  self.join_requests.pending.subject
  #end

  has_many :invitations, -> { where(:verb => 'invite', :target_type => 'User') }, :class_name => :Request, :as => :subject
  #, -> { where :verb => :invite, :target_type => :users }
  #has_many :invitees, :through => :invitations, :source => :target, :source_type => 'User', :conditions => { :status => Request::STATUS[:pending] } # TODO: expired_at condition

  has_many :filelinks, -> { includes(:file_attachment) }, :as => :root, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }

  VISIBILITY = Enumeration.new 0 => :public, 1 => :unlisted, 2 => :private
  MEMBERSHIP = Enumeration.new 0 => [:open,'Membership is open to the public'],
                               1 => [:invitation,'Membership is by invitation or applying to join'],
                               2 => [:application,'Membership is by applying to join or private invitation'],
                               3 => [:private,'Membership is by private invitation']

  def join(current_user)
    if self.members.exists?(current_user.id)
      false
    else
      self.members.push(current_user)
      # consider any pending invitations/applications accepted
      self.invitations.pending.where(:target_id => current_user.id).each(&:accept!)
      self.join_requests.pending.where(:subject_id => current_user.id).each(&:accept!)
      true
    end
  end

  def apply!(current_user, user = nil)
    user = current_user if user.nil?
    Request.create(:requester => current_user, :subject => user, :verb => :join, :target => self, :requestee => self.owner)
  end

  def invite!(user, current_user)
    Request.create(:requester => current_user, :subject => self, :verb => :invite, :target => user, :requestee => user)
  end
end


class Group < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, :class_name => :GroupMembership, :dependent => :destroy
  has_many :members, :through => :memberships
  has_and_belongs_to_many :problem_sets
  has_and_belongs_to_many :contests
  belongs_to :owner, :class_name => :User

  has_many :join_requests, :class_name => :Request, :as => :subject, :conditions => { :object_type => 'User', :verb => 'join' }
  #, -> { where :object_type => :users, :verb => :join }
  #has_many :applicants, :through => :applications, :source => :object, :source_type => 'User'
  #def applicants
  #  self.join_requests.pending.object
  #end

  has_many :invitations, :class_name => :Request, :as => :object, :conditions => { :verb => 'invite', :subject_type => 'User' }
  #, -> { where :verb => :invite, :subject_type => :users }
  #has_many :invitees, :through => :invitations, :source => :subject, :source_type => 'User', :conditions => { :status => Request::STATUS[:pending] } # TODO: expired_at condition

  # Scopes
  scope :distinct, select("distinct(groups.id), groups.*")

  VISIBILITY = Enumeration.new 0 => :public, 1 => :unlisted, 2 => :private
  MEMBERSHIP = Enumeration.new 0 => [:open,'Membership is open to the public'],
                               1 => [:invitation,'Membership is by invitation or applying to join'],
                               2 => [:application,'Membership is by applying to join or private invitation'],
                               3 => [:private,'Membership is by private invitation']

  def join(current_user)
    if self.members.exists?(current_user)
      false
    else
      self.members.push(current_user)
      # consider any pending invitations/applications accepted
      self.invitations.pending.where(:subject_id => current_user.id).each(&:accept!)
      self.applications.pending.where(:object_id => current_user.id).each(&:accept!)
      true
    end
  end

  def apply!(current_user, user)
    user = current_user if user.nil?
    Request.create(:requester => current_user, :object => user, :verb => :join, :subject => self, :requestee => self.owner)
  end

  def invite!(user, current_user)
    Request.create(:requester => current_user, :object => self, :verb => :invite, :subject => user, :requestee => user)
  end
end


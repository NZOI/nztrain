class Group < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, :class_name => :GroupMembership, :dependent => :destroy
  has_many :members, :through => :memberships
  has_and_belongs_to_many :problem_sets
  has_and_belongs_to_many :contests
  belongs_to :owner, :class_name => :User

  has_many :join_requests, :class_name => :Request, :as => :target, :conditions => { :subject_type => 'User', :verb => 'join' }
  #, -> { where :subject_type => :users, :verb => :join }
  #has_many :applicants, :through => :applications, :source => :subject, :source_type => 'User'
  #def applicants
  #  self.join_requests.pending.subject
  #end

  has_many :invitations, :class_name => :Request, :as => :subject, :conditions => { :verb => 'invite', :target_type => 'User' }
  #, -> { where :verb => :invite, :target_type => :users }
  #has_many :invitees, :through => :invitations, :source => :target, :source_type => 'User', :conditions => { :status => Request::STATUS[:pending] } # TODO: expired_at condition

  has_many :filelinks, :as => :root, :dependent => :destroy, :include => :file_attachment

  # Scopes
  scope :distinct, -> { select("distinct(groups.id), groups.*") }

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


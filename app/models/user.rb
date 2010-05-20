class User < ActiveRecord::Base

  #Scoping
  default_scope :order => 'username ASC'

  #Validations
  validates_presence_of :username, :full_name
  validates_uniqueness_of :username

  #Relationships
  has_and_belongs_to_many :groups
  has_many :revisions
  has_many :documents
  has_many :groups_led, :class_name => 'Group' , :foreign_key => 'group_leader_id'

  #Authenticates Access
  #is_admin and username can only be set by an admin
  authenticates_writes_to :is_admin, :with_accessor_method => :is_admin
  authenticates_writes_to :username, :with_accessor_method => :is_admin
  #users can only be saved by self or an admin.
  authenticates_saves :with => :allow_owner
  authenticates_saves :with_accessor_method => :is_admin
  #users can only read their own, unless they are admin
  authenticates_reads :with => :allow_owner
  authenticates_reads :with_accessor_method => :is_admin
  has_owner :self

  #Determine if a user belongs to at least one group
  def in_one_group?
    !self.groups.empty?
  end

  def in_one_group
    logger.info("DEPRECATION WARNING: ADD A ? TO IN ONE GROUP")
    !self.in_one_group?
  end

  #Used to test if a user is a member of a certain group.
  #Used by authenticates_access via method in model.
  def in_group?(options)
    result = false
    if options.is_a?(Hash)
      if (options.has_key? :group) && (options[:group].is_a?(Group))
        if self.groups.include?(options[:group])
          result = true
        end
      end
    elsif options.is_a?(Group)
      if self.groups.include?(options)
        result = true
      end
    end
    result
    #true
  end

  def to_param
    username
  end
end

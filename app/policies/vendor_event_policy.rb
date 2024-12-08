class VendorEventPolicy
  attr_reader :user, :vendor_event

  def initialize(user, vendor_event)
    @current_user = user
    @vendor_event = vendor_event
  end

  # Our policy is that an event should only be seen by the owner or followers
  #   of the owner, unless the owner is not private in which case anyone can
  #   see it

  def index?
    user == vendor_event.user_id ||
    !vendor_event.user.private? ||
    vendor_event.user.followers.include?(user)
  end

  def create?
    user == vendor_event.user_id
  end

  def update?
    user == vendor_event.user_id
  end

  def destroy?
    user == vendor_event.user_id
  end

  def show?
    user == vendor_event.user_id ||
      !vendor_event.user.private? ||
      vendor_event.user.followers.include?(user)
  end
end

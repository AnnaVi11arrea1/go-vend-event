class VendorEventPolicy
  attr_reader :current_user, :vendor_event

  def initialize(current_user, vendor_event)
    @current_user = current_user
    @vendor_event = vendor_event
  end

  def index?
    current_user == vendor_event.user ||
    !vendor_event.user.private? ||
    vendor_event.user.followers.include?(current_user)
  end

  def create?
    current_user == vendor_event.user
  end

  def update?
    current_user == vendor_event.user
  end

  def destroy?
    current_user == vendor_event.user
  end

  def show?
    current_user == vendor_event.user ||
      !vendor_event.user.private? ||
      vendor_event.user.followers.include?(current_user)
  end
end

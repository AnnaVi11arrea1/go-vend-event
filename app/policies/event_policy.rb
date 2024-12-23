class EventPolicy
  attr_reader :user, :event

  def initialize(user, event)
    @current_user = user
    @event = event
  end

  # Our policy is that an event should only be seen by the owner or followers
  #   of the owner, unless the owner is not private in which case anyone can
  #   see it
  def index?
    user == event.host ||
    !event.host.private? ||
    event.host.followers.include?(user)
  end



  def show?
    user == event.host ||
      !event.host.private? ||
      event.host.followers.include?(user)
  end
end

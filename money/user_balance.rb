class UserBalance < ActiveRecord::Base
  extend BalanceBehavior

  scope :by, lambda { |user_id| where(user_id: user_id) }

end

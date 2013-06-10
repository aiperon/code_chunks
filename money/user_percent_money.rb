class UserPercentMoney < ActiveRecord::Base
  include MoneyTransaction

  after_create 'balance_affect("create")'
  before_update 'balance_affect("update")'
  before_destroy 'balance_affect("destroy")'

  def self.target_balance
    UserBalance
  end

  def section_params
    {user_id: user_id, client_id: client_id}
  end

end

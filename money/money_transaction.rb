# coding: utf-8
module MoneyTransaction

  def balance_affect(action)
    affect(action, self.class.target_balance)
  end

  def affect(action, balance)
    params = self.section_params
    case action
    when "create"
      balance.wave(params, day: self.day, price: self.price)
    when "update"
      balance.wave(params, day: self.day, price: self.price, old_day: self.day_was, old_price: self.price_was)
    when "destroy"
      balance.wave(params, day: self.day, price: -self.price)
    end
  end

end

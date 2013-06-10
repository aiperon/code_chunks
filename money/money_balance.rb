class MoneyBalance < ActiveRecord::Base

  def self.movement_wave day, price, old_day = nil, old_price = nil, client_id = Client.first.id
    self.movement_wave(old_day, -old_price.to_i, nil, nil, client_id) if old_day
    if price != 0
      balance_today = MoneyBalance.find_or_create_by_day_and_client_id(day, client_id)
      balance_today.update_attribute("price", balance_today.price + price)
    end
  end

  def self.today(client_id)
    self.on_day Date.today, client_id
  end

  def self.on_day(day, client_id)
    MoneyBalance.mine(client_id).sum("price", :conditions => ["day <= ?",day])
  end

  def self.on_start(client_id)
    b = MoneyBalance.mine(client_id).first(:order => "day asc")
    b.nil? ? 0 : b.price
  end

  def self.date_of_start(client_id)
    b = MoneyBalance.mine(client_id).first(:order => "day asc")
    b.nil? ? Date.today : b.day
  end

  def self.restore(client_id)
    moves_on_day = MoneyMovement.mine(client_id).all(:select => "pay_day, sum(price) as price", :group => "pay_day")
    MoneyBalance.mine(client_id).destroy_all
    moves_on_day.each do |move|
      MoneyBalance.movement_wave(move.pay_day, move.price, nil, nil, client_id)
    end
  end

end

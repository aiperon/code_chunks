# coding: utf-8
module BalanceBehavior

  def today(section_params = {})
    on_day(section_params, Date.today)
  end

  def on_day(section_params = {}, day)
    where(section_params).where("day <= ?", day).sum("price")
  end

  def wave(section_params, options)
    single_wave(section_params.merge(day: options[:old_day]), -options[:old_price]) if options[:old_day]
    single_wave(section_params.merge(day: options[:day]), options[:price])
  end

  def single_wave(section_params,  price)
    if price != 0
      balance_day = where(section_params).first || create(section_params.merge(price: 0))
      balance_day.update_attribute(:price, balance_day.price + price)
    end
  end

end

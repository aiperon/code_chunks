# coding: utf-8
class MoneyMovement < ActiveRecord::Base

  scope :in, :conditions => "money_movements.price > 0"
  scope :out, :conditions => "money_movements.price < 0"

	validates_presence_of :pay_day, :price, :subject, :object
  DIRECTS = {"Расход" => "1", "Доход" => "2"}

  def direct=(direct)
    sign = direct == "1" ? -1 : 1
    update_attribute("price",price * sign) unless price.nil? || price == 0 || price/price.abs == sign
  end

  def direct
    price = self.price
    price ||= 0
    price <= 0 ? "1" : "2"
  end

  def self.standard_where(search = {})
    left = []
    right = []
    pay_day_from = search["pay_day_from"]
    pay_day_to = search["pay_day_to"]
    subject = search["subject"]
    object = search["object"]
    desc = search["desc"]
    direct = search["direct"]
    unless pay_day_from.blank?
      left << "money_movements.pay_day >= ?"
      right << Date.strptime(pay_day_from,"%d.%m.%Y")
    end
    unless pay_day_to.blank?
      left << "money_movements.pay_day <= ?"
      right << Date.strptime(pay_day_to,"%d.%m.%Y")
    end
    unless subject.blank?
      left << "(LOWER(subject) LIKE LOWER(?))"
      right << "%" + subject + "%"
    end
    unless object.blank?
      left << "(LOWER(object) LIKE LOWER(?))"
      right << "%" + object + "%"
    end
    unless desc.blank?
      left << "(LOWER(`desc`) LIKE LOWER(?))"
      right << "%" + desc + "%"
    end
    unless direct.blank?
      left << "money_movements.price > 0" if direct == "in"
      left << "money_movements.price < 0" if direct == "out"
    end
    [left,right]
  end

  def self.add val, options={}
  end

  def trigger
  end

  def self.transfer val, options={}
    default_options = {
      :subject => "наша компания",
      :pay_type => "нал",
      :desc => "",
      :doc_num => "",
      :pay_day => Date.today
    }
    default_options.merge!(options)
    if m = add(val, default_options)
      m.update_attribute(:client_id, default_options[:client_id])
      m.trigger
      MoneyBalance.movement_wave(default_options[:pay_day], val, nil, nil, m.client_id)
    end
  end


end

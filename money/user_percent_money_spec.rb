# coding: utf-8
require 'spec_helper'

describe UserPercentMoney do
  let(:month_ago) { 1.month.ago.to_date}
  let(:today) { Date.today }
  before(:each) { UserPercentMoney.create(client_id: 1, user_id: 1, order_id: 1, day: today, price: 10000) }

  describe "#create" do
    it "увеличивает баланс пользователя" do
      UserBalance.today(user_id: 1).should == 10000
    end
  end

  describe "#save" do
    it "обновляет баланс пользователя" do
      UserPercentMoney.first.update_attribute(:price, 12500)
      UserBalance.today(user_id: 1).should == 12500
    end

    context "при переносе процента на прошлый месяц" do
      before(:each) do
        UserPercentMoney.first.update_attribute(:day, month_ago)
      end

      it "увеличивает баланс в прошлом месяце" do
        UserBalance.on_day(1, month_ago).should == 10000
      end

      it "баланс в этом месяце не увеличивается" do
        UserBalance.on_day(1, today).should == 10000
      end

    end
  end

  describe "#destroy" do
    it "уменьшает баланс пользователя на сумму движения" do
      UserPercentMoney.find_by_order_id(1).destroy
      UserBalance.today(user_id: 1).should == 0
    end
  end
end

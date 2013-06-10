# coding: utf-8
require 'spec_helper'

describe UserBalance do
  let(:user) { stub("user", id: 1) }
  let(:client) { stub("client", id: 1) }
  let(:user_params) { {user_id: 1} }

  describe "#on_day" do
    context "при отсутствии каких-либо начислений," do

      it "показывает 0 на сегодняшний день" do
        UserBalance.on_day(user_params, Date.today).should == 0
      end

      it "показывает 0 на 2 недели назад" do
        UserBalance.on_day(user_params, 2.weeks.ago.to_date).should == 0
      end

    end

    context "при начислении 1000р неделю назад," do
      before(:each) do
        UserBalance.create!(user_id: user.id, client_id: client.id, day: 1.week.ago, price: 1000)
      end

      it "показывает 1000р на текущий день" do
        UserBalance.on_day(user_params, Date.today).should == 1000
      end
      it "показывает 1000р на неделю назад" do
        UserBalance.on_day(user_params, 1.week.ago.to_date).should == 1000
      end
      it "показывает 0р на 2 недели назад" do
        UserBalance.on_day(user_params, 2.weeks.ago.to_date).should == 0
      end

    end
  end

  describe "#wave" do

    it "создаёт объект баланса" do
      UserBalance.wave(user_params, {day: Date.today, price: 1000})
      UserBalance.by(user.id).count.should == 1
    end

    it "производит начисление на баланс пользователя" do
      UserBalance.wave(user_params, {day: Date.today, price: 1000})
      UserBalance.where(user_params.merge(day: Date.today)).first.price.should == 1000
    end

    context "при изменении начисленной суммы и даты начисления" do
      before(:each) do
        UserBalance.wave(user_params, {day: Date.today, price: 1000, old_day: 1.week.ago.to_date, old_price: 1000})
      end

      it "уменьшает баланс в предыдущую дату начисления" do
        UserBalance.where(day: 1.week.ago.to_date).first.price.should == -1000
      end

      it "увеличивает баланс на новую дату начисления" do
        UserBalance.where(day: Date.today).first.price.should == 1000
      end

    end
  end

end

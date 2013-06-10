class OrdersController < ApplicationController
  layout Proc.new { |controller| request.headers['X-PJAX'] ? false : 'staff' }

	def index
    @orders, @search = OrderSearch.compose_query(params, current_user, @default_order_field = 'created_at', @default_order_direct = 'desc')

    # для подсветки тех заявок, по которым менеджер пытался провести оплату
    @payed_by_notifications = []
    unload_id = OrderState.unload.id
    @orders.collect.each do |order|
      @payed_by_notifications << order.id if order.order_state_id == unload_id && order.payed_notifications.count>0
    end

    respond_to do |format|
      format.html{ render(request.headers['X-PJAX'] ? '_table' : 'index') }
      format.js
    end
	end

private

  def valid_search_params
    OrderSearch::PARAMS.keys
  end

end

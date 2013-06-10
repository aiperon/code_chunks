# coding: utf-8
class OrderSearch

  PARAMS = {
    debt: "Задолженность", 
    local_id: "Номер", 
    from_region_id: "Регион загрузки", 
    to_region_id: "Регион разгрузки", 
    user_id: "Менеджер", 
    driver_id: "Водитель", 
    vehicle_id: "Транспорт", 
    company_id: "Заказчик", 
    trucking_company_id: "Перевозчик", 
    our_company_id: "Работаем с заказчиком от", 
    our_company_for_driver_id: "Работаем с перевозчиком от", 
    created_at: "Дата создания", 
    pay_day: "Дата оплаты заказчиком", 
    pay_driver_day: "Дата оплаты перевозчику", 
    customer_pay_method: "Форма оплаты заказчиком", 
    transporter_pay_method: "Форма оплаты перевозчику", 
    order_by: "Задать порядок", 
    state_move: "Переводились в состояние", 
    state_have: "Находились в состоянии"
  }

  def self.single_condition(orders, field_name, value)
    value = value.split(':').uniq if value[':']
    value.blank? ? orders : orders.where(field_name.to_sym => value)
  end

  def self.date_grouped_condition(orders, field_name, value, search_params, is_datetime = false)
    value = value.split(':')
    date_from = search_params["#{field_name}_from"] || ''
    date_to = search_params["#{field_name}_to"] || ''
    if !''.in?(value) && (!date_from.blank? || !date_to.blank? || '0'.in?(value))
      date_from = date_from.split(':')
      date_to = date_to.split(':')
      left = []
      right = []
      value.each_with_index do |v, i|
        if v == '0'
          left << "isNull(orders.#{field_name})"
        else
          left1 = []
          unless (d = date_from[i]).blank?
            left1 << "orders.#{field_name} >= ?"
            right << Date.strptime(d, "%d.%m.%Y")
          end
          unless (d = date_to[i]).blank?
            left1 << "orders.#{field_name} <= ?"
            d = Date.strptime(d, "%d.%m.%Y")
            d += 1 if is_datetime
            right << d
          end
          left << left1.join(" AND ") unless left1.blank?
        end
      end
      orders = orders.where(left.join(' OR '), *right)
    end
    orders
  end

  def self.compose_query(search_params = {}, user, order_by, order_direct)
    orders = Order.where(client_id: user.client_id)
    if user.is?("менеджер")
      orders = orders.where(user_id: user.id)
      search_params.delete('user_id')
    end

    if (search_params.length == 2) && user.is?("бухгалтер") && search_params['pay_day'].blank?
      search_params['pay_day'] = '1:0'
      search_params['pay_day_to'] = I18n.l(Date.today) + ':'
      search_params['pay_day_from'] = ':'
    end

    from_tables = [ "orders" ]

    last_pay_method_id = (PayPart::METHODS.length - 1).to_s

    # TODO: вызывать построение параметра вручную!!!
    search_params.each_pair do |param, value|
      unless value.blank?
        case param
        when 'state_have'
          target = OrderState.find(value)
          v = target.id
          miss = v == OrderState.closed.id ? nil : OrderState.find(v + 1)
          from = search_params['state_have_from']
          to = search_params['state_have_to']
          from = from.blank? ? nil : Date.strptime(from,"%d.%m.%Y").strftime("%Y-%m-%d")
          to = to.blank? ? nil : Date.strptime(to,"%d.%m.%Y").strftime("%Y-%m-%d")
          orders = orders.in_condition_at(target, miss, from, to)
        when 'state_move'
          target = OrderState.find(value)
          v = target.id
          miss = v == OrderState.closed.id ? nil : OrderState.find(v + 1)
          from = search_params['state_move_from']
          to = search_params['state_move_to']
          from = from.blank? ? nil : Date.strptime(from,"%d.%m.%Y").strftime("%Y-%m-%d")
          to = to.blank? ? nil : Date.strptime(to,"%d.%m.%Y").strftime("%Y-%m-%d")
          orders = orders.has_state_move_at(target, miss, from, to)
        when 'state'
          v = value.split(':').uniq
          orders = orders.where(order_state_id: v) unless '0'.in?(v)
        when 'created_at'
          orders = date_grouped_condition(orders, param, value, search_params, true)
        when 'pay_day'
          orders = date_grouped_condition(orders, param, value, search_params, false)
        when 'pay_driver_day'
          orders = date_grouped_condition(orders, param, value, search_params, false)
        when 'customer_pay_method'
          value = value.split(':').uniq
          unless last_pay_method_id.in?(value)
            value << last_pay_method_id
            from_tables << 'pay_parts p1'
            orders = orders.where("orders.customer_pay_id = p1.id AND p1.method IN (?)", value)
          end
        when 'transporter_pay_method'
          value = value.split(':').uniq
          unless last_pay_method_id.in?(value)
            value << last_pay_method_id
            from_tables << 'pay_parts p2'
            orders = orders.where("orders.transporter_pay_id = p2.id AND p2.method IN (?)", value)
          end
        when 'debt'
          value = value.split(':').uniq
          if value.length > 1
            orders = orders.debt_in_out(Date.today)
          else
            value.map do |v|
              orders = v == 'customer' ? orders.debt_in(Date.today) : orders.debt_out(Date.today)
            end
          end
        when 'local_id'
          orders = single_condition(orders, param, value)
        when 'driver_id'
          orders = single_condition(orders, param, value)
        when 'vehicle_id'
          orders = single_condition(orders, param, value)
        when 'company_id'
          orders = single_condition(orders, param, value)
        when 'trucking_company_id'
          orders = single_condition(orders, param, value)
        when 'to_region_id'
          orders = single_condition(orders, param, value)
        when 'from_region_id'
          orders = single_condition(orders, param, value)
        when 'our_company_id'
          orders = single_condition(orders, param, value)
        when 'our_company_for_driver_id'
          orders = single_condition(orders, param, value)
        when 'user_id'
          orders = single_condition(orders, param, value)
        when 'order_by'
          direct = search_params["od"]
          if !direct.blank? && value.in?(%w[local_id price driver_price user_id created_at updated_at]) && direct.in?(['asc', 'desc'])
            order_by = value
            order_direct = direct
          end
          search_params[:order_by] = order_by
          search_params[:od] = order_direct
        end
      end
    end

    if (page = search_params[:page])
      page = page.to_i
      page = 1 if page <= 0
      search_params[:page] = page
    end
    orders = orders.from(from_tables.join(", ")).order("orders.#{order_by} #{order_direct}").page(page).per(20)

    [ orders, search_params ]
  end

end

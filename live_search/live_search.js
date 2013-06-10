function change_date_filter_period(){
  var form = $("#hidden_search_form:first form");
  $(this).closest("#date_period").find(".dateform").each(function(){
    fill_search_form(form, $(this), true)
  })
  pjax_submit(form)
}

function fill_search_form(form, object_with_value, without_submit, object_value){
  i = object_with_value.closest(".search_param").attr('data-copy-index')
  v = object_value || object_with_value.val()
  input = form.find("input[name='" + object_with_value.attr('name') + "']")
  if (i){
    arr_v = input.val().split(':')
    arr_v[i] = v
    v = arr_v.join(':')
  }
  input.val(v)
  if (!without_submit)
    pjax_submit(form)
}

function initLiveSearchForm(){
  var form = $("#hidden_search_form:first form");
  if (form.length == 0) return;
  form.pjaxform('#table_container');
  search_text_params = $('#search_text_params').on('change', '.search_param select.valuable', function(){
    t = $(this)
    if (t.hasClass("date_section")){
      date_period = t.closest(".search_param").find('#date_period')
      option = t.find('option:selected')
      if (option.attr('value') == t.find('option:last').attr('value'))
        date_period.css("display", "inline-block")
      else{
        date_period.find(".dateform:first").val(option.attr('data-from'))
        date_period.find(".dateform:last").val(option.attr('data-to'))
        date_period.css("display", "none")
      }
      fill_search_form(form, t, true)
      $.proxy(change_date_filter_period, date_period)()
    }else fill_search_form(form, $(this))
  }).on('keyup', '.search_param input.valuable', function(){
    input_class = this.getAttribute('class')
    if (input_class.indexOf('ui-autocomplete-input') == -1 && input_class.indexOf('dateform') == -1)
      fill_search_form(form, $(this))
  }).on('click', '.search_param input.valuable[type=checkbox]', function(){
    t = $(this)
    fill_search_form(form, t, false, t.is(':checked') ? '1' : '0')
  }).on('railsAutocomplete.select', '.search_param input.ui-autocomplete-input', function(event, data){
    input = $(this).closest(".search_param").find(this.getAttribute('data-custom-id-element'))
    input.val(data.item.id)
    fill_search_form(form, input)
  }).on('keypress', '.search_param input.ui-autocomplete-input', function(event, data){
    var e = $(this)
    setTimeout(function(){
      input = $(e.attr('data-custom-id-element'))
      if (e.val().length == 0){
        input.val("")
        fill_search_form(form, input)
      }
    }, 1)
  }).on('click', '.search_param a.icon.close', function(event){
    param_block = $(this).closest(".search_param")
    element_id = param_block.attr('data-id')
    same_blocks = param_block.closest("#search_text_params").children("[data-id=" + element_id + "]")
    search_inputs = param_block.find(".valuable")
    param_selector.find('#'+element_id).show()
    need_submit = false
    copy_index = param_block.attr('data-copy-index')
    for(i=0; i < search_inputs.length; i++){
      e = form.find("input[name='" + search_inputs[i].getAttribute('name') + "']")
      need_submit = need_submit || (e.val() != "")
      if (same_blocks.length == 1)
        e.remove()
      else{
        v = e.val().split(':')
        v[copy_index] = ''
        e.val(v.join(':'))
      }
    }
    if (same_blocks.length > 1 && copy_index == same_blocks[0].getAttribute('data-copy-index')){
      same_blocks[1].childNodes[0].data = param_block[0].childNodes[0].data
    }
    param_block.remove();
    if (need_submit){
      pjax_submit(form)
    }
  }).on('change', '.search_param #date_period input.valuable', change_date_filter_period)
  add_filter_block = search_text_params.find(".search_param#add_filter").on('mouseenter', function(){
    param_selector.show();
  }).on('mouseleave', function(){
    param_selector.hide();
  });
  var param_selector = add_filter_block.find("ul#param_selector").hide();

  $("body").on('click', 'table th .sortable .icon', function(event){
    sort_params = $(this).data('id').split('|')
    od_input = form.find("input[name='od']")
    if (od_input.length == 0){
      od_input = $("<input name='od' type='text'/>").appendTo(form)
      by_input = $("<input name='order_by' type='text'/>").appendTo(form)
    }else{
      by_input = form.find("input[name='order_by']")
    }
    od_input.val(sort_params[0]);
    by_input.val(sort_params[1]);
    pjax_submit(form)
  })

  $("body").on('click', '#paginator .page_nav_link', function(event){
    event.preventDefault();
    page_input = $("<input name='page' type='text'/>").appendTo(form)
    page_input.val($(this).data('id'))
    pjax_submit(form)
    page_input.remove()
  })
  $("body").on('keyup', '#paginator #page_num', function(event){
    page_input = $("<input name='page' type='text'/>").appendTo(form)
    page_input.val($(this).val())
    pjax_submit(form)
    page_input.remove()
  })

}

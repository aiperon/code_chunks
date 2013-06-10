$ -> 
  ## Механизм сборки содержания к странице
  firstLevel = []
  secondLevel = {}
  for header in body.children('h2,h3')
    if header.tagName.toLowerCase() == "h3"
      h_index = firstLevel.length
      continue unless h_index > 0
      secondLevel[h_index] ||= []
      secondLevel[h_index].push header
    else
      firstLevel.push header
    $("<a class='target'></a>").insertBefore(header)

  if firstLevel.length > 0
    header2toc = (header, level) ->
      header.attr('data-level', level)
      "<a data-target-level='#{level}'>#{level}. #{header.text()}</a>"

    toc = "<div id='toc'><h2>Содержание</h2><ul>"

    firstLevel.forEach (header, index) ->
      header = $(header)
      level = index + 1
      toc += "<li>"
      toc += header2toc(header, level)
      if secondLevel[level]?
        toc += "<ul>"
        subheaders = $.map secondLevel[level], (subheader, subindex) ->
          "<li>#{header2toc($(subheader), "#{level}.#{subindex + 1}")}</li>"
        toc += subheaders.join('')
        toc += "</ul>"
      toc += "</li>"

    toc += "</ul></div>"

    $(toc).insertAfter body.children('h1:first')

    $('#toc a').on 'click', (event) ->
      $('html, body').scrollTop(body.children("[data-level='#{$(@).data('target-level')}']").offset().top - $('#app_header').height() - 30)
      event.preventDefault()




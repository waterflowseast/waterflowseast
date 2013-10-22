$('fieldset a.preview').click ->
  $.post '/preview', { preview_content: $(this).closest('fieldset').find('textarea').val() }, (data) ->
    $('#preview_content').html(data)
    $('#preview').foundation('reveal', 'open')

$('#comments').on 'click', 'fieldset a.preview', ->
  $.post '/preview', { preview_content: $(this).closest('fieldset').find('textarea').val() }, (data) ->
    $('#preview_content').html(data)
    $('#preview').foundation('reveal', 'open')

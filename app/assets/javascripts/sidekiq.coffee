$(document).on 'turbolinks:load', ->
  checkSidekiqStatus = ->
    $.get '/status/sidekiq', (data) ->
      $('.system-status').removeClass('online offline')
      $('.system-status').addClass(data['status'])
      if data['status'] == 'online'
        $('.system-status').html('Sidekiq &amp; Daemon Online <i class="fa fa-check"></i>')
      else
        $('.system-status').html('Sidekiq &amp; Daemon Offline <i class="fa fa-times"></i>')

  checkSidekiqStatus()
  setInterval (->
    checkSidekiqStatus()
  ), 60000
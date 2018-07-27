$(document).on 'turbolinks:load', ->
  if $('#log').data('broadcast') && $('#log').data('perfCheckId') != undefined
    App.log_notifications = App.cable.subscriptions.create {channel: "LogNotificationsChannel", perf_check_id: $('#log').data('perfCheckId')}, {
      connected: ->
        console.log("LogNotificationsChannel: Connected")

      disconnected: ->
        console.log("LogNotificationsChannel: Disconnected")

      received: (data) ->
        console.log("LogNotificationsChannel: Recieved")
        console.log(data['status'])
        $('#log').html(data['contents'].replace("\n", "<br />"))
        $('#log').scrollTop($('#log')[0].scrollHeight)
        statusElems = $('.perf-check-status-' + $('#log').data('perfCheckId'))
        statusElems.html(data['status'])
        statusElems.removeClass('completed failed canceled running queued')
        statusElems.addClass(data['status'])
    }

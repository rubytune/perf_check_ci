$(document).on 'turbolinks:load', ->
  updateLogFileText = (data) ->
    $('#log').html(data['contents'].replace("\n", "<br />"))
    $('#log').scrollTop($('#log')[0].scrollHeight)

  updatePerfCheckStatus = (data) ->
    statusElems = $('.perf-check-status-' + data['id'])
    statusElems.html(data['status'])
    statusElems.removeClass('completed failed canceled running queued')
    statusElems.addClass(data['status'])

  
  App.log_notifications = App.cable.subscriptions.create {channel: "LogNotificationsChannel"}, {
    connected: ->
      console.log("LogNotificationsChannel: Connected")

    disconnected: ->
      console.log("LogNotificationsChannel: Disconnected")

    received: (data) ->
      console.log("LogNotificationsChannel: Recieved")
      console.log(data)
      if $('#log').data('broadcast') && $('#log').data('perfCheckId') == data['id']
        updateLogFileText(data)
      updatePerfCheckStatus(data)
  }

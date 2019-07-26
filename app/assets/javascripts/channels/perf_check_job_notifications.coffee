$(document).on 'turbolinks:load', ->
  updateLogFileText = (data) ->
    $('#log').html(data['contents'].replace("\n", "<br />"))
    $('#log').scrollTop($('#log')[0].scrollHeight)

  updatePerfCheckStatus = (data) ->
    statusElems = $('.perf-check-status-' + data['id'])
    statusElems.html(data['status'])
    statusElems.removeClass('completed failed canceled running queued')
    statusElems.addClass(data['status'])

  addNewPerfcheckJobToSidenav = (data) ->
    if $('.perf-check-status-' + data['id']).length == 0
      $('.browser-app-results').prepend("
        <li>
          <a href='/jobs/" + data['id'] + "'>
            <div data-link-to='/jobs/" + data['id'] + "'>
              <small class='pull-left status perf-check-status-" + data['id'] + " queued'>queued</small>
              <strong class='branch'>" + data['branch'] + "</strong>
              <small class='time'><i class='fa fa-clock-o'></i> less than a minute ago</small>
              <small class='name'>by " + data['username'] + "</small>
            </div>
          </a>
        </li>")

  App.log_notifications = App.cable.subscriptions.create {channel: "PerfCheckJobNotificationsChannel"}, {
    connected: ->
      console.log("PerfCheckJobNotificationsChannel: Connected")

    disconnected: ->
      console.log("PerfCheckJobNotificationsChannel: Disconnected")

    received: (data) ->
      console.log("PerfCheckJobNotificationsChannel: Received")
      console.log(data)
      updatePerfCheckStatus(data) # Updates sidenav and the currently viewed page if applicable
      if $('#log').data('broadcast') && $('#log').data('perfCheckId') == data['id'] && data['broadcast_type'] == 'log_file_stream'
        updateLogFileText(data)
      if data['broadcast_type'] == 'new_perf_check'
        addNewPerfcheckJobToSidenav(data)
  }

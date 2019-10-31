App.logs_channel = App.cable.subscriptions.create('StatusChannel', {
  received: function(data) {
    var element = $(`.perf-check-status-${data.id}`)
    if (element.length == 0) {
      $('.browser-app-results').prepend(`
        <li>
          <a href="/jobs/${data.id}">
            <div data-link-to="/jobs/${data.id}">
              <small class="pull-left status perf-check-status-${data.id} queued">queued</small>
              <strong class="branch">${data.experimental_branch}</strong>
              <small class="time"><i class="fa fa-clock-o"></i> less than a minute ago</small>
              <small class="name">by ${data.user_name}</small>
            </div>
          </a>
        </li>
      `)
    } else {
      element.html(data.status)
      element.removeClass('completed failed canceled running queued')
      element.addClass(data.status)
    }
  }
})

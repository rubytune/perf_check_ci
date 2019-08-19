App.logs_channel = App.cable.subscriptions.create('LogsChannel', {
  received: function(data) {
    var element = $('[data-perf-check-id="' + data.id + '"]')
    element.html(data.contents)
    element.scrollTop(element.prop('scrollHeight'))
  }
})
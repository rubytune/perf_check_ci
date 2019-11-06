$(document).on 'turbolinks:load', ->
  loadMoreResults = ->
    currentPageData = $('#load-more-results').data()

  addPerfcheckJobToSidenav = (data) ->
    if $('.perf-check-status-' + data['id']).length == 0
      $('.browser-app-results').append("
        <li>
          <a href='/jobs/" + data['id'] + "'>
            <div data-link-to='/jobs/" + data['id'] + "'>
              <small class='pull-left status perf-check-status-" + data['id'] + " " + data['status'] + "'>" + data['status'] + "</small>
              <strong class='branch'>" + data['experiment_branch'] + "</strong>
              <small class='time'><i class='fa fa-clock-o'></i> less than a minute ago</small>
              <small class='name'>by " + data['user_name'] + "</small>
            </div>
          </a>
        </li>")

  $('#load-more-results').click ->
    $('#load-more-results').html('Loading More ...')
    currentPageData = $('#load-more-results').data()
    page = parseInt(currentPageData["page"]) + 1
    per = parseInt(currentPageData["per"]) || ''
    search = currentPageData["search"] || ''

    $('#load-more-results').data({page: page, per: per, search: search})
    $.get '/jobs.json?page='+page+'&per='+per+'&search='+search, (data) ->
      if (!data)
        $('#load-more-results').html('Load More Results')
        return false;

      $.each data["jobs"], (key, job) ->
        addPerfcheckJobToSidenav(job)
        return

      if data["jobs"].length == 0
        $('#load-more-results').hide()

      $('#load-more-results').html('Load More Results')
    return false

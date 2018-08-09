$(document).on 'turbolinks:load', ->
  loadMoreResults = ->
    currentPageData = $('#load-more-results').data()

  addPerfcheckJobToSidenav = (data) ->
    if $('.perf-check-status-' + data['id']).length == 0
      $('.browser-app-results').append("
        <li>
          <a href='/perf_check_jobs/" + data['id'] + "'>
            <div data-link-to='/perf_check_jobs/" + data['id'] + "'>
              <small class='pull-left status perf-check-status-" + data['id'] + " " + data['status'] + "'>" + data['status'] + "</small>
              <strong class='branch'>" + data['branch'] + "</strong>
              <small class='time'><i class='fa fa-clock-o'></i> less than a minute ago</small>
              <small class='name'>by " + data['username'] + "</small>
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
    $.get '/perf_check_jobs.json?page='+page+'&per='+per+'&search='+search, (data) ->
      $.each data["perf_check_jobs"], (key, perf_check_job) ->
        addPerfcheckJobToSidenav(perf_check_job)
        return
      
      if data["perf_check_jobs"].length == 0
        $('#load-more-results').hide()

      $('#load-more-results').html('Load More Results')
    return false

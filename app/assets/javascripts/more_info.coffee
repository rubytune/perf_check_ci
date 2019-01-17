$(document).on 'turbolinks:load', ->
  $('.test-case .show-more-info').click ->
    $(this).fadeOut()
    $(this).closest('.test-case').find('.more-info').slideDown()
    return false
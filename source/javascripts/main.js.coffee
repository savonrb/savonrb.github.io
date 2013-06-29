$ ->

  # syntax highlighting
  hljs.initHighlightingOnLoad()

  # delayed code block icons, because highlight.js
  # can be a little slow and doesn't provide a callback.
  setTimeout ->
    console.log 'bla'
    $('pre code').each ->
      classes = $(this).attr('class')
      $(this).parent().addClass(classes)
  , 200

  # mobile navigation
  $('#nav')
    .clone()
    .removeAttr('id')
    .addClass('nav-copy')
    .prependTo($('#mobile-nav'))

  $('#mobile-nav .trigger').on 'click', (event) ->
    event.preventDefault()
    $(this).parent().toggleClass('on')

  # floating link-list
  $('#floating-link-list a')
    .on('mouseenter', (e) -> $(this).parent().addClass('on'))
    .on('mouseleave', (e) -> $(this).parent().removeClass('on'))

  # highlight navigation
  classes = $('body').attr('class').split(' ')
  if classes.length == 2
    version = classes[0]
    pageName = classes[1].split('_')[1]

    $('#mobile-nav li a, #nav li a').each ->
      $this = $(this)

      if $this.attr('href').match(pageName)
        $this.parent().addClass('on')

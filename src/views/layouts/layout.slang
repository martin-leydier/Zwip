doctype html
html style="background-color: #f9f9fa;"
  head
    title Zwip
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
    meta name="mobile-web-app-capable" content="yes"
    meta name="apple-mobile-web-app-capable" content="yes"
    meta name="apple-mobile-web-app-status-bar-style" content="black"
    link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.css"
    script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"
    script src="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.js"
    link rel="stylesheet" href="/css/site.css"
    script src="https://unpkg.com/nprogress@0.2.0/nprogress.js"
    script src="/js/site.js"


  body
    .ui.fixed.inverted.icon.menu
      .ui.container
        #breadcrumb.ui.breadcrumb.header.item
          a.section href="/" onclick="event.preventDefault();navigateContent('/')"
            i.inverted.home.icon.path-separator
          - path = "/"
          - env.request.path.split('/', remove_empty: true).each do |part|
            - path += part + "/"
            a.section href=path
              i.right.angle.small.icon.inverted.path-separator
              == URI.unescape part
        #rightmenu.right.icon.menu
          a#download.item href="/.download" onclick="event.preventDefault();navigateContent('/.download')"
            i.download.icon.inverted
          a.item href="/.list" onclick="event.preventDefault();navigateContent('/.list')"
            #cart.ui.black.label style="margin-left: 0;"
              i.cart.arrow.down.icon.inverted
              = get_cart(env).size
          a.header.item target="_blank" rel="noopener noreferrer" href="https://github.com/martin-leydier/Zwip"
            img src="/images/logo.webp"
              ' Zwip

    #content.ui.main.container
      == content

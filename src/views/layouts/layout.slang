doctype html
html
  head
    title Zwip
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
    meta name="mobile-web-app-capable" content="yes"
    meta name="apple-mobile-web-app-capable" content="yes"
    meta name="apple-mobile-web-app-status-bar-style" content="black"
    link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.css"
    script src="https://code.jquery.com/jquery-3.1.1.min.js" integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=" crossorigin="anonymous"
    script src="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.js"
    link rel="stylesheet" href="/css/site.css"


  body
    .ui.fixed.inverted.icon.menu
      .ui.container
        #breadcrumb.ui.breadcrumb.header.item
          a.section href="/"
            i.inverted.home.icon.path-separator
          - acu = "/"
          - env.request.path.split('/', remove_empty: true).each do |part|
            - acu += part + "/"
            a.section href=acu
              i.right.angle.small.icon.inverted.path-separator
              == URI.unescape part
        #rightmenu.right.icon.menu
          a#download.item href="/.download"
            i.download.icon.inverted
          a.item href="/.list"
            #cart.ui.black.label style="margin-left: 0;"
              i.cart.arrow.down.icon.inverted
              = get_cart(env).size
          a.header.item href="https://github.com/martin-leydier/Zwip"
            img src="/images/logo.webp"
              ' Zwip

    .ui.main.container
      == content

script src="/js/site.js"
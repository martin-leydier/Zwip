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
    script src="https://unpkg.com/nprogress@0.2.0/nprogress.js"
    link rel="stylesheet" href="/css/normalize.css"
    link rel="stylesheet" href="/css/fontawesome.css"
    link rel="stylesheet" href="/css/tooltips.css"
    link rel="stylesheet" href="/css/new_site.css"
    script src="/js/site.js?v=1.2"

  body
    .header
      #breadcrumb.item
        a.tooltip.tooltip-bottom href="/" onclick="event.preventDefault();navigateContent('/')" data-tooltip="Home"
          i.fas.fa-home
        - if env.request.path == "/.list"
          i.fas.fa-slash.path-separator
          a.tooltip.tooltip-bottom href="/.list" onclick="event.preventDefault();navigateContent('/.cart')" data-tooltip="Cart"
            i.fas.fa-cart-arrow-down
        - elsif env.request.path == "/.download"
          i.fas.fa-slash.path-separator
          a.tooltip.tooltip-bottom href="/.download" onclick="event.preventDefault();navigateContent('/.download')" data-tooltip="Download cart"
            i.fas.fa-download
        - else
          - path = "/"
          - env.request.path.split('/', remove_empty: true).each do |part|
            - path += part + "/"
            i.fas.fa-slash.path-separator
            a href=path
              == HTML.escape(URI.decode_www_form part)
      #rightmenu
        a.item.tooltip.tooltip-bottom#download data-tooltip="Download cart" href="/.download" onclick="event.preventDefault();navigateContent('/.download')"
          i.fas.fa-download
        a.item.tooltip.tooltip-bottom data-tooltip="Cart" href="/.list" onclick="event.preventDefault();navigateContent('/.list')"
          i.fas.fa-cart-arrow-down style="margin-right: .5rem;"
          span#cartCount
            = get_cart(env).size
        a.item target="_blank" rel="noopener noreferrer" href="https://github.com/martin-leydier/Zwip"
          img src="/images/logo.webp"
          | Zwip

    #content
      == content

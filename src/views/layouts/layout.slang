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
    link rel="stylesheet" href="/css/normalize.css"
    link rel="stylesheet" href="/css/fontawesome.min.css?v=#{version}"
    link rel="stylesheet" href="/css/solid.min.css?v=#{version}"
    link rel="stylesheet" href="/css/tooltips.css?v=#{version}"
    link rel="stylesheet" href="/css/site.css?v=#{version}"
    link rel="shortcut icon" href="/favicon.ico"
    script src="/js/site.js?v=#{version}"

  body
    .header
      #breadcrumb.item
        a.header-inline-icon href="/" onclick="event.preventDefault();navigateContent('/')" data-tooltip="Home"
          i.fas.fa-fw.fa-home.larger-icon
          span.pl Home
        - if env.request.path == "/.list"
          i.fas.fa-fw.fa-slash.path-separator
          a.header-inline-icon href="/.list" onclick="event.preventDefault();navigateContent('/.cart')" data-tooltip="Cart"
            i.fas.fa-fw.fa-cart-arrow-down.larger-icon
            span.pl Cart
        - elsif env.request.path == "/.download"
          i.fas.fa-fw.fa-slash.path-separator
          a.header-inline-icon href="/.download" onclick="event.preventDefault();navigateContent('/.download')" data-tooltip="Download"
            i.fas.fa-fw.fa-download.larger-icon
            span.pl Download
        - else
          - path = "/"
          - env.request.path.split('/', remove_empty: true).each do |part|
            - path += part + "/"
            i.fas.fa-fw.fa-slash.path-separator
            a href=path onclick="event.preventDefault();navigateContent('#{path}')"
              == HTML.escape(URI.decode_www_form part, plus_to_space: false)
      #rightmenu
        a.item.tooltip.tooltip-bottom#download data-tooltip="Download cart" href="/.download" onclick="event.preventDefault();navigateContent('/.download')"
          i.fas.fa-fw.fa-download
        a.item.tooltip.tooltip-bottom data-tooltip="Cart" href="/.list" onclick="event.preventDefault();navigateContent('/.list')"
          i.fas.fa-fw.fa-cart-arrow-down style="margin-right: .5rem;"
          span#cartCount
            = get_cart(env).size
        a.hide-sm.item target="_blank" rel="noopener noreferrer" href="https://github.com/martin-leydier/Zwip"
          img src="/images/logo.webp"
          | Zwip

    #content
      == content

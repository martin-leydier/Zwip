#items
  - if env.request.path != "/"
    a href="#{env.request.path}.." onclick="event.preventDefault();navigateContent('#{URI.encode_www_form env.request.path}..')"
      i.icon.left.arrow
      ' ..
  - files.each do |file|
    hr
    - if file.directory?
      - lnk = "#{file.basename}/"
    - else
      - lnk = ""
    a href=lnk onclick="event.preventDefault();navigateContent('#{URI.encode_www_form lnk}')"
      - unless file.directory?
        = file.size.humanize_bytes
      = file.basename
      .ui.basic.right.floated.icon.button onclick="event.preventDefault();instantDownload('#{URI.encode_www_form file.path}');"
        i.download.icon
      .ui.basic.right.floated.icon.button onclick="event.preventDefault();addCart('#{URI.encode_www_form file.path}');"
        i.cart.plus.icon

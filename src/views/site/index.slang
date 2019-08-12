#items
  - if env.request.path != "/"
    a.header href="#{env.request.path}.." onclick="event.preventDefault();navigateContent('#{URI.escape env.request.path}..')"
      .ui.middle.aligned.vertical.segment
        h5.ui.header
          i.icon.left.arrow
          .content
            ' ..
  - files.each do |file|
    .ui.fitted.divider
    - if file.directory?
      - lnk = "#{file.basename}/"
    - else
      - lnk = ""
    a.header href=lnk onclick="event.preventDefault();navigateContent('#{URI.escape lnk}')"
      .ui.vertical.clearing.tight.segment
        h5.ui.left.vertically-centered.floated.header
          - unless file.directory?
            .ui.right.floated.label
              = file.size.humanize_bytes
          i.icon class=file.icon
          .content
            = file.basename
        .ui.right.floated.basic.buttons
          .ui.basic.right.floated.icon.button onclick="event.preventDefault();instantDownload('#{URI.escape file.path}');"
            i.download.icon
          .ui.basic.right.floated.icon.button onclick="event.preventDefault();addCart('#{URI.escape file.path}');"
            i.cart.plus.icon

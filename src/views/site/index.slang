#items
  - if env.request.path != "/"
    a.header href="#{env.request.path}.." onclick="event.preventDefault();navigateContent('#{env.request.path}..')"
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
    a.header href=lnk onclick="event.preventDefault();navigateContent('#{lnk}')"
      .ui.vertical.clearing.segment
        h5.ui.left.vertically-centered.floated.header
          - unless file.directory?
            .ui.right.floated.label
              = file.size.humanize_bytes
          i.icon class=file.icon
          .content
              = file.basename
        .ui.basic.right.floated.icon.button onclick="event.preventDefault();addCart('#{file.path}');"
          i.cart.plus.icon

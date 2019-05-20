.ui.segments
  - cart.each do |file|
    .ui.clearing.segment
      h5.ui.left.vertically-centered.floated.header
        - unless file.directory?
          .ui.right.floated.label
            = file.size.humanize_bytes
        i.icon class="#{file.icon}"
        .content
          = file.path
      .ui.right.floated.red.icon.button onclick="removeFromCart('#{file.path}', this.parentNode);"
        i.close.icon

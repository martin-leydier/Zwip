.entry.tooltip.tooltip-bottom data-tooltip="Go back home"
  a.highlightable.entry-link href="/" onclick="event.preventDefault();navigateContent('/')"
    i.fas.fa-home
    .content
      ' Home
.spacer
.empty#emptyCart hidden=!cart.empty?
  .content
    span.fa-stack.fa-2x
      i.fas.fa-file.fa-stack-1x
      i.fas.fa-slash.fa-stack-1x
      i.fas.fa-slash.fa-stack-1x.double-slash
    h3 ' Your cart is empty
#entries
  - cart.each do |file|
    .entry
      - if file.directory?
        a.entry-link
          i.fas.fa-folder
          .content
            = file.basename
          .size-badge
            = file.size.humanize_bytes
      - else
        .entry-link
          i.fas.fa-file
          .content
            = file.basename
          .size-badge
            = file.size.humanize_bytes
      .entry-buttons
        a.entry-button.highlightable.tooltip.tooltip-bottom data-tooltip="Download entry" href="/.zip?files=#{URI.encode_www_form file.path, space_to_plus: false}"
          i.fas.fa-download
        .entry-button.highlightable.tooltip.tooltip-bottom.danger data-tooltip="Remove from cart" onclick="removeFromCart('#{URI.encode_www_form file.path, space_to_plus: false}', this.parentNode.parentNode);"
          i.fas.fa-trash-alt

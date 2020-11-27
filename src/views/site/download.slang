.entry.tooltip.tooltip-bottom data-tooltip="Go back home"
  a.highlightable.entry-link href="/" onclick="event.preventDefault();navigateContent('/')"
    i.fas.fa-home
    .content
      | Home
.spacer
.empty
  .content
    i.fas.fa-file-archive.fa-3x
    h3 | Zip
    - if cart_empty?(env)
      | Cart is empty
    - else
      a.button href="#{build_dl(env)}" onclick="clearCart();"
        i.download.icon
        ' Download
  hr
  .content
    i.fas.fa-link.fa-3x
    h3 | Multi-link
    - if cart_empty?(env)
      | Cart is empty
    - else
      .button.tooltip.tooltip-bottom.tooltip-large data-tooltip="Multi-link download will start one download per file in the cart. This allows you to pause/resume your download. Depending on the number of files, you may experience issues like crashes or slow-downs.\nYou may also get a warning from your browser about trying to download multiple files.\nThis requires JavaScript to be enabled" onclick="multiDownload()"
        i.download.icon
        ' Download

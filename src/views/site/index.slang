#entries
  - if env.request.path != "/"
    .entry.tooltip.tooltip-bottom data-tooltip="Go back to parent directory"
      a.highlightable.entry-link href="#{env.request.path}.." onclick="event.preventDefault();navigateContent('#{URI.encode_www_form env.request.path, space_to_plus: false}..')"
        i.fas.fa-fw.fa-arrow-left
        .content.mono
          = get_prev_folder(env.request.path)
  - files.each do |file|
    - if file.directory?
      - lnk = "#{file.basename}/"
    - else
      - lnk = ""
    .entry
      - if file.directory?
        a.highlightable.entry-link href=lnk onclick="event.preventDefault();navigateContent('#{URI.encode_www_form lnk, space_to_plus: false}')"
          i.fas.fa-fw.fa-folder
          .content.mono
            = file.basename
      - else
        .entry-link
          i.fas.fa-fw class=file.icon
          .space-between.mono
            .content
              = file.basename
            .size-badge
              = file.size.humanize_bytes
      .entry-buttons
        a.entry-button.highlightable.tooltip.tooltip-bottom download="" data-tooltip="Download entry" href="/.zip?files=#{URI.encode_www_form file.path, space_to_plus: false}"
          i.fas.fa-fw.fa-download
        .entry-button.highlightable.tooltip.tooltip-bottom data-tooltip="Add to cart" onclick="event.preventDefault();addCart('#{URI.encode_www_form file.path, space_to_plus: false}');"
          i.fas.fa-fw.fa-cart-plus

#multiDlWarning.ui.basic.modal
  .ui.icon.header
    i.linkify.icon
    ' Multi-link download
  .content
    p Multi-link download will start one download per file in the cart. This allows you to pause/resume your download. Depending on the number of files, you may experience issues like crashes or slow-downs.
    br
    p You may also get a warning from your browser about trying to download multiple files.
  .actions
    .ui.red.basic.cancel.inverted.button
      i.remove.icon
      ' Cancel
    .ui.green.ok.inverted.button onclick="multiDownload()"
      i.checkmark.icon
      ' Understood

.ui.placeholder.segment
  .ui.two.column.stackable.center.aligned.divided.grid
    .middle.aligned.row
      .column
        .ui.icon.header
          i.file.archive.icon
          ' Zip
        a.ui.primary.labeled.icon.button href="#{build_dl(env)}" onclick="clearCart();"
          i.download.icon
          ' Download
      .column
        .ui.icon.header
          i.linkify.icon
          ' Multi-link
        .ui.primary.labeled.icon.button onclick="$('#multiDlWarning').modal('show');"
          i.download.icon
          ' Download

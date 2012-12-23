jQuery ->
  $('#new_upload').fileupload
    dataType: "script"
    maxFileSize: 5000000
    maxNumberOfFiles: 10
    add: (e, data) ->
      that = $(this).data('fileupload')
      options = that.options
      types = /(\.|\/)(pdf)$/i
      file = data.files[0]
      quota = options.maxNumberOfFiles - $('#uploads > .row').length
      if !(types.test(file.type) || types.test(file.name))
        file.error = "Wrong file format"
      else if (file.size > options.maxFileSize)
        file.error = "File is too big"
      else if (quota < 1)
        file.error = "Max number of files exceeded"
      file.size_with_format = options._formatFileSize(file.size)
      data.context = $(tmpl("template-upload", file))
      $('#uploading').append(data.context)
      if !(file.error)
        data.submit()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
    done: (e, data) ->
      data.context.hide('slow')

    _formatFileSize: (bytes) ->
      if (typeof bytes != 'number')
        return ''
      if (bytes >= 1000000000)
        return (bytes / 1000000000).toFixed(2) + ' GB'
      if (bytes >= 1000000)
        return (bytes / 1000000).toFixed(2) + ' MB'
      return (bytes / 1000).toFixed(2) + ' KB'
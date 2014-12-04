
fs = require 'fs'
path = require 'path'
{Range,$,View} = require 'atom'
parse = require 'lcov-parse'

module.exports =
class HighlightCovView extends View
  @content: -> @div ''

  initialize: (serializeState) ->
    atom.workspaceView.command 'highlight-cov:toggle', => @toggle()
    atom.workspaceView.eachEditorView (e) =>
      @refreshCovInfo()
    @refreshCovInfo()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log 'toggling coverage info'
    if @hasParent()
      @removeCovInfo()
      @detach()
    else
      atom.workspaceView.append(this)
      @refreshCovInfo()

  removeCovInfo: =>
    if (@decorations)
      @decorations.forEach (decoration) =>
        decoration.destroy()
    @decorations = []

  refreshCovInfo: =>
    editor = atom.workspace.getActiveEditor()
    return unless editor

    @removeCovInfo()
    filePath = editor.buffer.file.path
    infoFilePath = @findLCovInfoFile(filePath)
    if not infoFilePath
      console.log 'no coverage info found at this folder'
      return

    parse infoFilePath, (err, data) =>
      fileData = (data.filter (f) => (filePath.substr(filePath.length - f.file.length) == f.file))[0]
      if not fileData
        console.log 'no coverage info found for this file'
        return
      fileData.lines.details.forEach (detail) =>
        # line 7
        range = [[detail.line - 1, 0], [detail.line - 1, 0]];

        marker = editor.markBufferRange(range, invalidate: 'touch')
        type = 'line'

        return unless editor.decorateMarker
        className = if detail.hit > 0 then 'has-coverage' else 'no-coverage'
        decoration = editor.decorateMarker(marker, type: type, class: className)
        @decorations.push(decoration)

  findLCovInfoFile: (filePath) ->
    while filePath and filePath != path.dirname(filePath)
      filename = path.join(filePath, 'coverage', 'lcov.info')
      console.log('LCOV looking at ', filename)
      if (fs.existsSync(filename))
        console.log('found LCOV info at ', filename)
        return filename
      filePath = path.dirname(filePath)
    return null

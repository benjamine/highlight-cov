HighlightCovView = require './highlight-cov-view'

module.exports =
  highlightCovView: null

  activate: (state) ->
    @highlightCovView = new HighlightCovView(state.highlightCovViewState)

  deactivate: ->
    @highlightCovView.destroy()

  serialize: ->
    highlightCovViewState: @highlightCovView.serialize()

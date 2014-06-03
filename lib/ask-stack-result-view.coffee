{ScrollView} = require 'atom'

module.exports =
class AskStackResultView extends ScrollView
  @content: ->
    @div class: 'ask-stack-result', tabindex: -1, =>
      @span "test"

  constructor: ({@editorId}) ->
    super

    if @editorId?
      @resolveEditor(@editorId)
      @toggle()

  destroy: ->
    @unsubscribe()

  getTitle: ->
    "Ask Stack Results"

  toggle: ->
    uri = "ask-stack-result://#{@editorId}"

    previewPane = atom.workspace.paneForUri(uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForUri(uri))
      return

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (askStackResultView) ->
      if askStackResultView instanceof AskStackResultView
        renderAnswers()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents()

    if atom.workspace?
      resolve()

  editorForId: (editorId) ->
    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson) ->
    # Do stuff

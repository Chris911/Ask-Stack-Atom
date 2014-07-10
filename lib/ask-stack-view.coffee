url = require 'url'

{EditorView, View} = require 'atom'

AskStack = require './ask-stack'
AskStackApiClient = require './ask-stack-api-client'
AskStackResultView = require './ask-stack-result-view'

module.exports =
class AskStackView extends View
  @content: ->
    @div class: 'ask-stack overlay from-top padded', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @span 'Ask Stack Overflow'
        @div class: 'panel-body padded', =>
          @div =>
            @subview 'questionField', new EditorView(mini:true, placeholderText: 'Question (eg. Sort array)')
            @subview 'tagsField', new EditorView(mini:true, placeholderText: 'Language / Tags (eg. Ruby;Rails)')
            @div class: 'pull-right', =>
              @button outlet: 'askButton', class: 'btn btn-primary', ' Ask! '
            @div class: 'pull-left', =>
              @label 'Sort by:'
              @br()
              @label for: 'relevance', class: 'radio-label', 'Relevance: '
              @input outlet: 'sortByRelevance', id: 'relevance', type: 'radio', name: 'sort_by', value: 'relevance', checked: 'checked'
              @label for: 'votes', class: 'radio-label last', 'Votes: '
              @input outlet: 'sortByVote', id: 'votes', type: 'radio', name: 'sort_by', value: 'votes'
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    @handleEvents()

    atom.workspaceView.command 'ask-stack:ask-question', => @presentPanel()

    atom.workspace.registerOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'ask-stack:'

      return new AskStackResultView()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  handleEvents: ->
    @askButton.on 'click', => @askStackRequest()

    @questionField.on 'core:confirm', => @askStackRequest()
    @questionField.on 'core:cancel', => @detach()

    @tagsField.on 'core:confirm', => @askStackRequest()
    @tagsField.on 'core:cancel', => @detach()

    @subscribe atom.config.observe 'ask-stack.autoDetectLanguage', callNow: false, (autoDetect) =>
      @tagsField.getEditor().setText("") unless autoDetect
      @needRedraw = true

  presentPanel: ->
    atom.workspaceView.append(this)

    @progressIndicator.hide()
    if @needRedraw
      @tagsField.redraw()
      @needRedraw = false
    @questionField.focus()
    @setLanguageField() if atom.config.get('ask-stack.autoDetectLanguage')

  askStackRequest: ->
    @progressIndicator.show()

    AskStackApiClient.resetInputs()
    AskStackApiClient.question = @questionField.getText()
    AskStackApiClient.tag = @tagsField.getText()
    AskStackApiClient.sort_by = if @sortByVote.is(':checked') then 'votes' else 'relevance'
    AskStackApiClient.search (response) =>
      @progressIndicator.hide()
      this.detach()
      if response == null
        alert('Encountered a problem with the Stack Exchange API')
      else
        @showResults(response)

  showResults: (answersJson) ->
    uri = 'ask-stack://result-view'

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (askStackResultView) ->
      if askStackResultView instanceof AskStackResultView
        askStackResultView.renderAnswers(answersJson)
        atom.workspace.activatePreviousPane()

  setLanguageField: ->
    lang = @getCurrentLanguage()
    return if lang == null or lang == 'Null Grammar'
    @tagsField.getEditor().setText(lang)

  getCurrentLanguage: ->
    editor = atom.workspace.getActiveEditor()
    if editor == undefined then null else editor.getGrammar().name

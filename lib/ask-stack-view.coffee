url = require 'url'

{CompositeDisposable} = require 'event-kit'
{TextEditorView, View} = require 'atom-space-pen-views'

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
            @subview 'questionField', new TextEditorView(mini:true, placeholderText: 'Question (eg. Sort array)')
            @subview 'tagsField', new TextEditorView(mini:true, placeholderText: 'Language / Tags (eg. Ruby;Rails)')
            @div class: 'pull-right', =>
              @br()
              @button outlet: 'askButton', class: 'btn btn-primary', ' Ask! '
            @div class: 'pull-left', =>
              @br()
              @label 'Sort by:'
              @br()
              @label for: 'relevance', class: 'radio-label', 'Relevance: '
              @input outlet: 'sortByRelevance', id: 'relevance', type: 'radio', name: 'sort_by', value: 'relevance', checked: 'checked'
              @label for: 'votes', class: 'radio-label last', 'Votes: '
              @input outlet: 'sortByVote', id: 'votes', type: 'radio', name: 'sort_by', value: 'votes'
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ask-stack:ask-question', => @presentPanel()

    @handleEvents()

    @autoDetectObserveSubscription =
      atom.config.observe 'ask-stack.autoDetectLanguage', (autoDetect) =>
        _this.tagsField.setText("") unless autoDetect

    atom.workspace.addOpener (uriToOpen) ->
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
    @hideView()
    @detach()

  hideView: ->
    @panel.hide()
    @.focusout()

  onDidChangeTitle: ->
  onDidChangeModified: ->

  handleEvents: ->
    @askButton.on 'click', => @askStackRequest()

    @subscriptions.add atom.commands.add @questionField.element,
      'core:confirm': => @askStackRequest()
      'core:cancel': => @hideView()

    @subscriptions.add atom.commands.add @tagsField.element,
      'core:confirm': => @askStackRequest()
      'core:cancel': => @hideView()

  presentPanel: ->
    #atom.workspaceView.append(this)
    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)

    @panel.show()
    @progressIndicator.hide()
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
      this.hideView()
      if response == null
        alert('Encountered a problem with the Stack Exchange API')
      else
        @showResults(response)

  showResults: (answersJson) ->
    uri = 'ask-stack://result-view'

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).then (askStackResultView) ->
      if askStackResultView instanceof AskStackResultView
        askStackResultView.renderAnswers(answersJson)
        atom.workspace.activatePreviousPane()

  setLanguageField: ->
    lang = @getCurrentLanguage()
    return if lang == null or lang == 'Null Grammar'
    @tagsField.setText(lang)

  getCurrentLanguage: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor == undefined then null else editor.getGrammar().name

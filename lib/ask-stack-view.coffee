url = require 'url'

{EditorView, View} = require 'atom'

AskStack = require './ask-stack-model'
AskStackResultView = require './ask-stack-result-view'

module.exports =
class AskStackView extends View
  @content: ->
    @div class: "ask-stack overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span "Ask StackOverflow"
        @div class: "panel-body padded", =>
          @div outlet: 'signupForm', =>
            @subview 'questionEditor', new EditorView(mini:true, placeholderText: 'Question (eg. Sort array)')
            @subview 'languageEditor', new EditorView(mini:true, placeholderText: 'Language (eg. Ruby)')
            @div class: 'pull-right', =>
              @button outlet: 'askButton', class: 'btn btn-primary', "Ask!"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'
        @div class: "panel-body padded", =>
          @div outlet: 'resultsPanel', =>

  initialize: (serializeState) ->
    @handleEvents()
    @askStack = null
    atom.workspaceView.command "ask-stack:presentPanel", => @presentPanel()

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
    @questionEditor.on 'core:confirm', => @askStackRequest()
    @languageEditor.on 'core:confirm', => @askStackRequest()
    @questionEditor.on 'core:cancel', => @detach()
    @languageEditor.on 'core:cancel', => @detach()

  presentPanel: ->
    @askStack = new AskStack()

    this.show()
    atom.workspaceView.append(this)

    @progressIndicator.hide()
    @resultsPanel.hide()
    @questionEditor.focus()

  askStackRequest: ->
    @progressIndicator.show()

    @askStack.question = @questionEditor.getText()
    @askStack.tag = @languageEditor.getText()
    @askStack.search (response) =>
      @progressIndicator.hide()
      this.hide()
      showResults(response)

  showResults = (answersJson) ->
    uri = "ask-stack://result-view"

    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (askStackResultView) ->
      if askStackResultView instanceof AskStackResultView
        askStackResultView.renderAnswers(answersJson)
        previousActivePane.activate()

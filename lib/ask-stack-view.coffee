{EditorView, View} = require 'atom'

AskStack = require './ask-stack-model'

module.exports =
class AskStackView extends View
  @content: ->
    @div class: "ask-stack overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span "Ask StackOverflow"
        @div class: "panel-body padded", =>
          @div outlet: 'signupForm', =>
            @subview 'questionEditor', new EditorView(mini:true, placeholderText: 'Enter Question')
            @div class: 'pull-right', =>
              @button outlet: 'askButton', class: 'btn btn-primary', "Ask!"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    @handleEvents()
    @askStack = null
    atom.workspaceView.command "ask-stack:presentPanel", => @presentPanel()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  handleEvents: ->
    @askButton.on 'click', => @askStackRequest()
    @questionEditor.on 'core:confirm', => @askStackRequest()
    @questionEditor.on 'core:cancel', => @detach()

  presentPanel: ->
    @askStack = new AskStack()

    atom.workspaceView.append(this)

    @progressIndicator.hide()
    @questionEditor.focus()

  askStackRequest: ->
    @progressIndicator.show()

    @askStack.question = @questionEditor.getText()
    @askStack.tag = "ruby"
    @askStack.search (response) =>
      console.log(response)

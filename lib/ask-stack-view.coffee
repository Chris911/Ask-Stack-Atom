{View} = require 'atom'

module.exports =
class AskStackView extends View
  @content: ->
    @div class: 'ask-stack overlay from-top', =>
      @div "The AskStack package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "ask-stack:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AskStackView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

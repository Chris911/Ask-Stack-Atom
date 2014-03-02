{EditorView, View} = require 'atom'

module.exports =
class AskTaskResultView extends View
  @content: ->
    @div =>
      @subview 'questionEditor', new EditorView(mini:true, placeholderText: 'Question (eg. Sort array)')
      @div class: 'pull-right', =>
        @button outlet: 'copyButton', class: 'btn btn-primary', "Copy"

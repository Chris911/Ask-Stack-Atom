AskStackView = require './ask-stack-view'

module.exports =
  configDefaults:
    autoDetectLanguage: false
  askStackView: null

  activate: (state) ->
    @askStackView = new AskStackView(state.askStackViewState)

  deactivate: ->
    @askStackView.destroy()

  serialize: ->
    askStackViewState: @askStackView.serialize()

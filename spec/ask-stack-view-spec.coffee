AskStackView = require '../lib/ask-stack-view'
{WorkspaceView} = require 'atom'

describe "AskStackView", ->
  askStackView = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    askStackView = new AskStackView()

  describe "when the panel is presented", ->
    it "displays all the components", ->
      askStackView.presentPanel()

      runs ->
        expect(askStackView.questionField).toExist()
        expect(askStackView.tagsField).toExist()
        expect(askStackView.sortByVote).toExist()
        expect(askStackView.askButton).toExist()

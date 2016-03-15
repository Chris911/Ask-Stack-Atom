AskStackView = require '../lib/ask-stack-view'

describe "AskStackView", ->
  askStackView = null

  beforeEach ->
    askStackView = new AskStackView()

  describe "when the panel is presented", ->
    it "displays all the components", ->
      askStackView.presentPanel()

      runs ->
        expect(askStackView.questionField).toExist()
        expect(askStackView.tagsField).toExist()
        expect(askStackView.sortByVote).toExist()
        expect(askStackView.askButton).toExist()

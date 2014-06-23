{$, EditorView, WorkspaceView} = require 'atom'

AskStackResultView = require '../lib/ask-stack-result-view'

describe "AskStackResultView", ->
  resultView = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    resultView = new AskStackResultView()

  describe "when search returns no result", ->
    it "displays a proper messaged is displayed", ->
      json = require('./data/no_matches.json')

      resultView.renderAnswers(json, false)

      runs ->
        text = resultView.text()
        expect(text).toBe("Your search returned no matches.")

  describe "when search returns a list of results", ->
    it "only shows a maximum of 5 results", ->
      json = require('./data/data.json')

      resultView.renderAnswers(json, false)

      runs ->
        results = resultView.find("#results-view").children().length
        expect(results).toBe(5)

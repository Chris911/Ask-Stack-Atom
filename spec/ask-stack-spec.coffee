{$, EditorView, WorkspaceView} = require 'atom'

AskStack = require '../lib/ask-stack'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AskStack", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('ask-stack')

  describe "when the ask-stack:ask-question event is triggered", ->
    it "attaches the view", ->
      expect(atom.workspaceView.find('.ask-stack')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'ask-stack:ask-question'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.ask-stack')).toExist()

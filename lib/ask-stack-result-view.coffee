{$, $$$, ScrollView} = require 'atom-space-pen-views'
AskStackApiClient = require './ask-stack-api-client'
hljs = require 'highlight.js'

window.jQuery = $
require './vendor/bootstrap.min.js'

module.exports =
class AskStackResultView extends ScrollView
  @content: ->
    @div class: 'ask-stack-result native-key-bindings', tabindex: -1, =>
      @div id: 'results-view', outlet: 'resultsView'
      @div id: 'load-more', class: 'load-more', click: 'loadMoreResults', outlet: 'loadMore', =>
        @a href: '#loadmore', =>
          @span  'Load More...'
      @div id: 'progressIndicator', class: 'progressIndicator', outlet: 'progressIndicator', =>
        @span class: 'loading loading-spinner-medium'

  initialize: ->
    super

  getTitle: ->
    'Ask Stack Results'

  getURI: ->
    'ask-stack://result-view'

  getIconName: ->
    'three-bars'

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson, loadMore = false) ->
    @answersJson = answersJson

    # Clean up HTML if we are loading a new set of answers
    @resultsView.html('') unless loadMore

    if answersJson['items'].length == 0
      this.html('<br><center>Your search returned no matches.</center>')
    else
      # Render the question headers first
      for question in answersJson['items']
        @renderQuestionHeader(question)

      # Then render the questions and answers
      for question in answersJson['items']
        @renderQuestionBody(question)

  renderQuestionHeader: (question) ->
    # Decode title html entities
    title = $('<div/>').html(question['title']).text();
    questionHeader = $$$ ->
      @div id: question['question_id'], class: 'ui-result', =>
        @h2 class: 'title', =>
          @a href: question['link'], class: 'underline title-string', title
          @div class: 'score', =>
            @p question['score']
        @div class: 'created', =>
          @text new Date(question['creation_date'] * 1000).toLocaleString()
        @div class: 'tags', =>
          for tag in question['tags']
            @span class: 'label label-info', tag
            @text '\n'
        @div class: 'collapse-button'

    # Space-pen doesn't seem to support the data-toggle and data-target attributes
    toggleBtn = $('<button></button>', {
      id: "toggle-#{question['question_id']}",
      type: 'button',
      class: 'btn btn-info btn-xs',
      text: 'Show More'
    })
    toggleBtn.attr('data-toggle', 'collapse')
    toggleBtn.attr('data-target', "#question-body-#{question['question_id']}")

    html = $(questionHeader).find('.collapse-button').append(toggleBtn).parent()
    @resultsView.append(html)

  renderQuestionBody: (question) ->
    curAnswer = 0
    quesId = question['question_id']

    # This is mostly only rendered here and not with the answer because we need
    # the full question object to know how many answers there are. Might be a good
    # thing to refactor this at some point and render the navigation with the answer.
    if question['answer_count'] > 0
      answer_tab = "<a href='#prev#{quesId}'><< Prev</a>   <span id='curAnswer-#{quesId}'>#{curAnswer+1}</span>/#{question['answers'].length}  <a href='#next#{quesId}'>Next >></a> "
    else
      answer_tab = "<br><b>This question has not been answered.</b>"

    # Leaving as HTML for now as space-pen doesn't support data-toggle attribute
    # Also struggling with <center> and the navigation link
    div = $('<div></div>', {
      id: "question-body-#{question['question_id']}"
      class: "collapse hidden"
      })
    div.html("
    <ul class='nav nav-tabs nav-justified'>
      <li class='active'><a href='#question-#{quesId}' data-toggle='tab'>Question</a></li>
      <li><a href='#answers-#{quesId}' data-toggle='tab'>Answers</a></li>
    </ul>
    <div id='question-body-#{question['question_id']}-nav' class='tab-content hidden'>
      <div class='tab-pane active' id='question-#{quesId}'>#{question['body']}</div>
      <div class='tab-pane answer-navigation' id='answers-#{quesId}'>
        <center>#{answer_tab}</center>
      </div>
    </div>")

    $("##{quesId}").append(div)

    @highlightCode("question-#{quesId}")
    @addCodeButtons("question-#{quesId}")
    if question['answer_count'] > 0
      @renderAnswerBody(question['answers'][curAnswer], quesId)
      @setupNavigation(question, curAnswer)

    # Question toggle button
    $("#toggle-#{quesId}").click (event) ->
      btn = $(this)
      if ( $("#question-body-#{quesId}").hasClass('in') )
        $("#question-body-#{quesId}").addClass('hidden')
        $("#question-body-#{quesId}-nav").addClass('hidden')
        btn.parents("##{quesId}").append(btn.parent())
        $(this).text('Show More')
      else
        $("#question-body-#{quesId}").removeClass('hidden')
        $("#question-body-#{quesId}-nav").removeClass('hidden')
        btn.parent().siblings("#question-body-#{quesId}").append(btn.parent())
        btn.text('Show Less')

  renderAnswerBody: (answer, question_id) ->
    answerHtml = $$$ ->
      @div =>
        @a href: answer['link'], =>
          @span class: 'answer-link', '➚'
        @span class: 'label label-success', 'Accepted' if answer['is_accepted']
        @div class: 'score answer', =>
          @p answer['score']

    $("#answers-#{question_id}").append($(answerHtml).append(answer['body']))

    @highlightCode("answers-#{question_id}")
    @addCodeButtons("answers-#{question_id}")

  highlightCode: (elem_id) ->
    pres = @resultsView.find("##{elem_id}").find('pre')
    for pre in pres
      code = $(pre).children('code').first()
      if(code != undefined)
        codeHl =  hljs.highlightAuto(code.text()).value
        code.html(codeHl)

  addCodeButtons: (elem_id) ->
    pres = @resultsView.find("##{elem_id}").find('pre')
    for pre in pres
      btnInsert = @genCodeButton('Insert')
      $(pre).prev().after(btnInsert)

  genCodeButton: (type) ->
    btn = $('<button/>',
    {
        text: type,
        class: 'btn btn-default btn-xs'
    })
    if type == 'Insert'
      $(btn).click (event) ->
        code = $(this).next().next('pre').text()
        if code != undefined
          atom.workspace.activatePreviousPane()
          editor = atom.workspace.activePaneItem
          editor.insertText(code)

    return btn

  loadMoreResults: ->
    if @answersJson['has_more']
      @progressIndicator.show()
      @loadMore.hide()
      AskStackApiClient.page = AskStackApiClient.page + 1
      AskStackApiClient.search (response) =>
        @loadMore.show()
        @progressIndicator.hide()
        @renderAnswers(response, true)
    else
      $('#load-more').children().children('span').text('No more results to load.')

  setupNavigation: (question, curAnswer) ->
    quesId = question['question_id']

    # Answers navigation
    $("a[href='#next#{quesId}']").click (event) =>
        if curAnswer+1 >= question['answers'].length then curAnswer = 0 else curAnswer += 1
        $("#answers-#{quesId}").children().last().remove()
        $("#curAnswer-#{quesId}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], quesId)

    $("a[href='#prev#{quesId}']").click (event) =>
        if curAnswer-1 < 0 then curAnswer = question['answers'].length-1 else curAnswer -= 1
        $("#answers-#{quesId}").children().last().remove()
        $("#curAnswer-#{quesId}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], quesId)

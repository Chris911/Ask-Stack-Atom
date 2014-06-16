{$, $$$, ScrollView} = require 'atom'
AskStackApiClient = require './ask-stack-api-client'
hljs = require 'highlight.js'
clipboard = require 'copy-paste'

require './ext/bootstrap.min.js'

module.exports =
class AskStackResultView extends ScrollView
  @content: ->
    @div class: 'ask-stack-result native-key-bindings', tabindex: -1

  initialize: ->
      super

  destroy: ->
    @unsubscribe()

  getTitle: ->
    'Ask Stack Results'

  getUri: ->
    'ask-stack://result-view'

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson, loadMore = false) ->
    if answersJson['items'].length == 0
      @html('<br /><center>Your search returned no matches.</center>')
    else
      html = if loadMore then @html() else ''

      # Render the question headers first
      for question in answersJson['items']
        questionHtml = @renderQuestionHeader(question)
        html += questionHtml

      loadMoreBtn = "<div id='load-more' class='load-more'><a href='#loadmore'><span>Load More...</span></a></div>"
      progressIndicator = "<div id=\"progressIndicator\" class=\"progressIndicator\"><span class=\"loading loading-spinner-medium\"></span></div>"

      html += loadMoreBtn
      html += progressIndicator

      # Initial HTML
      @html(html)

      # Then render the questions and answers
      for question in answersJson['items']
        @renderQuestionBody(question)

      $("a[href=\"#loadmore\"]").click (event) =>
          if answersJson['has_more']
            $('#progressIndicator').show()
            $('#load-more').remove()
            AskStackApiClient.page = AskStackApiClient.page + 1
            AskStackApiClient.search (response) =>
              $('#progressIndicator').remove()
              @renderAnswers(response, true)
          else
            $('#load-more').children().children('span').text('No more results to load.')

  renderQuestionHeader: (question) ->
    html = "
    <div class=\"ui-result\" id=\"#{question['question_id']}\">
      <h2 class=\"title\">
      <a class=\"underline title-string\" href=\"#{question['link']}\">
        #{question['title']}
      </a>
      <div class=\"score\"><p>#{question['score']}</p></div>
    </h2>
    <div class=\"created\">
      #{new Date(question['creation_date'] * 1000).toLocaleString()}
    </div>
    <div class=\"tags\">"
    for tag in question['tags']
      html += "<span class=\"label label-info\">#{tag}</span>\n"
    html += "</div>
    <div class=\"collapse-button\">
      <button id=\"toggle-#{question['question_id']}\" type=\"button\" class=\"btn btn-info btn-xs\" data-toggle=\"collapse\" data-target=\"#question-body-#{question['question_id']}\">
        Show More
      </button>
    </div>
    </div>"

  renderQuestionBody: (question) ->
    curAnswer = 0
    quesId = question['question_id']
    div = document.createElement('div');
    div.setAttribute( "id", "question-body-#{question['question_id']}")
    div.setAttribute( "class", "collapse" );
    div.innerHTML = "
    <ul class=\"nav nav-tabs nav-justified\">
      <li class=\"active\"><a href=\"#question-#{quesId}\" data-toggle=\"tab\">Question</a></li>
      <li><a href=\"#answers-#{quesId}\" data-toggle=\"tab\">Answers</a></li>
    </ul>
    <div class=\"tab-content\">
      <div class=\"tab-pane active\" id=\"question-#{quesId}\">#{question['body']}</div>
      <div class=\"tab-pane\" id=\"answers-#{quesId}\">
        <center><a href=\"#prev#{quesId}\"><< Prev</a>   <span id=\"curAnswer-#{quesId}\">#{curAnswer+1}</span>/#{question['answers'].length}  <a href=\"#next#{quesId}\">Next >></a> </center>
      </div>
    </div>"
    document.getElementById("#{quesId}").appendChild(div)
    @highlightCode(quesId)
    @addCodeButtons(quesId)

    @renderAnswerBody(question['answers'][curAnswer], quesId)

    @setupClickEvents(question, curAnswer)

  renderAnswerBody: (answer, question_id) ->
    div = $('<div></div>')
    div.append("<a href=\"#{answer['link']}\"><span class=\"answer-link\">➚</span></a>")
    div.append("<span class=\"label label-success\">Accepted</span>") if answer['is_accepted']
    score = $("<div class=\"score answer\"><p>#{answer['score']}</p></div>")
    div.append(score)
    div.append(answer['body'])
    $("#answers-#{question_id}").append(div)

    @highlightCode("answers-#{question_id}")
    @addCodeButtons("answers-#{question_id}")

  highlightCode: (elem_id) ->
    pres = document.getElementById(elem_id).getElementsByTagName('pre');
    for pre in pres
      code = $(pre).children('code').first()
      if(code != undefined)
        codeHl =  hljs.highlightAuto(code.text()).value
        code.html(codeHl)

  addCodeButtons: (elem_id) ->
    pres = document.getElementById(elem_id).getElementsByTagName('pre');
    for pre in pres
      btnInsert = @genCodeButton('Insert')
      btnCopy = @genCodeButton('Copy')
      $(pre).prev().after(btnInsert)
      $(pre).prev().after(btnCopy)

  genCodeButton: (type) ->
    btn = $('<button/>',
    {
        text: type,
        class: 'btn btn-default btn-xs'
    })
    if type == 'Copy'
      $(btn).click (event) ->
        code = $(this).next('pre').text()
        clipboard.copy(code) if code != undefined
        atom.workspace.activatePreviousPane()

    if type == 'Insert'
      $(btn).click (event) ->
        code = $(this).next().next('pre').text()
        if code != undefined
          atom.workspace.activatePreviousPane()
          editor = atom.workspace.activePaneItem
          editor.insertText(code)

    return btn

  setupClickEvents: (question, curAnswer) ->
    quesId = question['question_id']
    # This has to be done after the initial HTML is rendered
    $("#toggle-#{quesId}").click (event) ->
      btn = $(this)
      if ( $("#question-body-#{quesId}").hasClass('in') )
        btn.parents("##{quesId}").append(btn.parent())
        $(this).text('Show More')
      else
        btn.parent().siblings("#question-body-#{quesId}").append(btn.parent())
        btn.text('Show Less')

    $("a[href=\"#next#{quesId}\"]").click (event) =>
        if curAnswer+1 >= question['answers'].length then curAnswer = 0 else curAnswer += 1
        $("#answers-#{quesId}").children().last().remove()
        $("#curAnswer-#{quesId}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], quesId)

    $("a[href=\"#prev#{quesId}\"]").click (event) =>
        if curAnswer-1 < 0 then curAnswer = question['answers'].length-1 else curAnswer -= 1
        $("#answers-#{quesId}").children().last().remove()
        $("#curAnswer-#{quesId}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], quesId)

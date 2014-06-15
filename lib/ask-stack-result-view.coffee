{$, $$$, ScrollView} = require 'atom'
hljs = require 'highlight.js'

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
    "Ask Stack Results"

  getUri: ->
    "ask-stack://result-view"

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson) ->
    html = ''

    for question in answersJson['items']
      questionHtml = @renderQuestionHeader(question)
      html += questionHtml

    @html(html)

    @renderQuestionBody(answersJson['items'][0])
    @renderQuestionBody(answersJson['items'][1])
    @renderQuestionBody(answersJson['items'][2])

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
    </div>"

  renderQuestionBody: (question) ->
    curAnswer = 0
    quesId = question['question_id']
    div = document.createElement('div');
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

  renderAnswerBody: (answer, question_id) ->
    div = $("<div></div>").append(answer['body'])
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
      btnInsert = @genButton('Insert')
      btnCopy = @genButton('Copy')
      $(pre).prev().after(btnInsert)
      $(pre).prev().after(btnCopy)

  genButton: (text) ->
    $('<button/>',
    {
        text: text,
        class: 'btn btn-default btn-xs'
    })

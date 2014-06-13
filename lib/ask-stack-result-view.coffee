{$, $$$, ScrollView} = require 'atom'

require './bootstrap/bootstrap.min.js'

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
    div = document.createElement('div');
    div.innerHTML = "
    <ul class=\"nav nav-tabs nav-justified\">
      <li class=\"active\"><a href=\"#question\" data-toggle=\"tab\">Question</a></li>
      <li><a href=\"#answers\" data-toggle=\"tab\">Answers</a></li>
    </ul>
    <div class=\"tab-content\">
      <div class=\"tab-pane active\" id=\"question\">#{question['body']}</div>
      <div class=\"tab-pane\" id=\"answers\">#{question['answers'][0]['body']}</div>
    </div>"
    document.getElementById("#{question['question_id']}").appendChild(div)

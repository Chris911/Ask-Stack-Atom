https = require 'https'
zlib = require 'zlib'

module.exports =
class AskStack
  constructor: ->
      @question = ""
      @tag = ""

  search: (callback) ->
    cb = callback
    @getQuestions (questions) =>
      @getCodeSamples(@getAnswers(questions), cb)

  getQuestions: (callback) ->
      options =
        hostname: 'api.stackexchange.com'
        path: "/2.2/search?order=desc&sort=votes&pagesize=3&tagged=#{encodeURIComponent(@tag.trim())}&intitle=#{encodeURIComponent(@question.trim())}&site=stackoverflow"
        method: 'GET'
        headers:
          "User-Agent": "Atom-Ask-Stack"
          "accept-encoding" : "gzip"

      request = https.request options, (res) ->
        buffer = []
        gunzip = zlib.createGunzip();
        res.pipe(gunzip)

        gunzip.on "data", (chunk) ->
          buffer.push(chunk.toString())
        gunzip.on "end", ->
          #debugger
          body = buffer.join("")
          response = JSON.parse(body)
          callback(response)

        gunzip.on "error", (e) ->
          console.log "Error: #{e.message}"

      request.end()

  getAnswers: (questions) ->
    answers = []
    console.log(questions)
    for item, items in questions['items']
      if item['accepted_answer_id'] != undefined
        answers.push(item['accepted_answer_id'])
    return answers

  getCodeSamples: (answers, callback) ->

    options =
      hostname: 'api.stackexchange.com'
      path: "/2.2/answers/#{answers.join(';')}?order=desc&sort=activity&site=stackoverflow&filter=withbody"
      method: 'GET'
      headers:
        "User-Agent": "Atom-Ask-Stack"
        "accept-encoding" : "gzip"

    request = https.request options, (res) ->
      buffer = []
      gunzip = zlib.createGunzip();
      res.pipe(gunzip)

      gunzip.on "data", (chunk) ->
        buffer.push(chunk.toString())
      gunzip.on "end", ->
        #debugger
        body = buffer.join("")
        response = JSON.parse(body)
        console.log "SAMPLE CALLBACK"
        callback(response)

      gunzip.on "error", (e) ->
        console.log "Error: #{e.message}"

    request.end()

https = require 'https'
zlib = require 'zlib'
module.exports =

class AskStack
  constructor: ->
      @question = ""
      @tag = ""

  search: (callback) ->
    options =
      hostname: 'api.stackexchange.com'
      path: "/2.2/search?order=desc&sort=votes&max=10&tagged=#{encodeURIComponent(@tag.trim())}&intitle=#{encodeURIComponent(@question.trim())}&site=stackoverflow"
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
        debugger
        body = buffer.join("")
        response = JSON.parse(body)
        callback(response)

      gunzip.on "error", (e) ->
        console.log "Error: #{e.message}"

    #request.write(JSON.stringify(@toParams()))

    request.end()

  replaceSace: (text) ->

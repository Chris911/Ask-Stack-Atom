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
        path: "/2.2/search/advanced?pagesize=5&" +
        "order=desc&" + "sort=votes&" +
        "q=#{encodeURIComponent(@question.trim())}&" +
        "tagged=#{encodeURIComponent(@tag.trim())}&" +
        "site=stackoverflow&" +
        "filter=!b0OfNKD*3O569e"
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

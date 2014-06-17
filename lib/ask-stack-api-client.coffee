https = require 'https'
zlib = require 'zlib'

module.exports =
class AskStackApiClient

  # Properties
  @question = ''
  @tag = ''
  @page = 1
  @sort_by = 'votes'

  @search: (callback) ->
      options =
        hostname: 'api.stackexchange.com'
        path: "/2.2/search/advanced?pagesize=5&" +
        "page=#{@page}&" +
        "order=desc&" +
        "sort=#{@sort_by}&" +
        "q=#{encodeURIComponent(@question.trim())}&" +
        "tagged=#{encodeURIComponent(@tag.trim())}&" +
        "site=stackoverflow&" +
        "filter=!b0OfNKD*3O569e"
        method: 'GET'
        headers:
          'User-Agent': 'Atom-Ask-Stack'
          'accept-encoding' : 'gzip'

      request = https.request options, (res) ->
        buffer = []
        gunzip = zlib.createGunzip();
        res.pipe(gunzip)

        gunzip.on 'data', (chunk) ->
          buffer.push(chunk.toString())
        gunzip.on 'end', ->
          #debugger
          body = buffer.join("")
          response = JSON.parse(body)
          callback(response)

        gunzip.on 'error', (e) ->
          console.log "Error: #{e.message}"

      request.end()

  @resetInputs: ->
    @question = ''
    @tag = ''
    @page = 1
    @sort_by = 'votes'

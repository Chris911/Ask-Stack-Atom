https = require 'https'
zlib = require 'zlib'

module.exports =
#
# With the current model where we can only have 1 result page opened at once
# this class is "static" because we want to share the API client between the
# views easily. This way we can load more results by keeping track of the last
# requested page. If at some point we decide we can have more than one result
# page at the same time this class should be instanciated and passed from the
# 'Ask Stack' view to the result view.
#
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
          try
            response = JSON.parse(body)
          catch
            response = null
          finally
            callback(response)

        gunzip.on 'error', (e) ->
          console.log "Error: #{e.message}"

      request.end()

  @resetInputs: ->
    @question = ''
    @tag = ''
    @page = 1
    @sort_by = 'votes'

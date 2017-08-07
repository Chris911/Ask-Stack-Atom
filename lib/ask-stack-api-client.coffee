request = require 'request'
fs = require 'fs'

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
      uri: "https://api.stackexchange.com" +
        "/2.2/search/advanced?pagesize=5&" +
        "page=#{@page}&" +
        "order=desc&" +
        "sort=#{@sort_by}&" +
        "q=#{encodeURIComponent(@question.trim())}&" +
        "tagged=#{encodeURIComponent(@tag.trim())}&" +
        "site=stackoverflow&" +
        "filter=!b0OfNKD*3O569e"
      method: 'GET'
      gzip: true
      ca: fs.readFileSync "./certFile.pem"
      headers:
        'User-Agent': 'Atom-Ask-Stack'

    options.proxy = process.env.http_proxy if process.env.http_proxy?

    request options, (error, res, body) ->
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null

  @resetInputs: ->
    @question = ''
    @tag = ''
    @page = 1
    @sort_by = 'votes'

''
'' Retrieves information from the BoxCast API
''

function BoxCastAPI()
  this = {
    GetBroadcastsForChannel: GetBroadcastsForChannel
    GetBroadcastById: GetBroadcastById
    UpdateBroadcastViewMeta: UpdateBroadcastViewMeta
    PostMetrics: PostMetrics
  }
  return this
end function

function GetBroadcastsForChannel(channelId, query)
  cfg = BoxCastConfig()
  result = CreateObject("roSGNode", "ContentNode")

  if query = invalid or query = "" then
    query = cfg.defaultChannelQueryString
  end if

  ' grabbing all the data for the playlist at once can result in a huge chunk of JSON
  ' and processing that into a BS structure can crash the box
  url = cfg.apiRoot + "channels/" + channelId + "/broadcasts?" + query
  print "Getting broadcasts for channel from: ";url
  raw = GetStringFromURL(url)
  json = ParseJSON(raw)

  if json = invalid then
    return false
  end if

  for each broadcast in json
    result.appendChild(ContentNodeFromBroadcastJson(broadcast))
  next

  return result
end function

function GetBroadcastById(broadcastId)
  cfg = BoxCastConfig()

  url = cfg.apiRoot + "broadcasts/" + broadcastId
  print "Getting broadcast from: ";url
  broadcastData = GetStringFromURL(url)
  jsonBroadcast = ParseJSON(broadcastData)
  if jsonBroadcast = invalid
    return invalid
  end if

  return ContentNodeFromBroadcastJson(jsonBroadcast)
end function

function ContentNodeFromBroadcastJson(broadcast)
  previewUrl = strReplace(ValidStr(broadcast.preview), " ", "%20")

  ' https://sdkdocs.roku.com/display/sdkdoc/Content+Meta-Data
  content = CreateObject("roSGNode", "ContentNode")
  content.id =                      ValidStr(broadcast.id)
  content.contentId =               ValidStr(broadcast.id)
  content.name =                    ValidStr(broadcast.name)
  content.shortDescriptionLine1 =   ValidStr(broadcast.name)
  content.shortDescriptionLine2 =   Left(ValidStr(broadcast.description), 60)
  content.title =                   ValidStr(broadcast.name)
  content.description =             ValidStr(broadcast.description)
  content.synopsis =                ValidStr(broadcast.description)
  content.sdPosterURL =             ValidStr(previewUrl)
  content.hdPosterURL =             ValidStr(previewUrl)
  content.streamFormat =            "hls"
  content.contentType =             "episode"
  content.categories =              []
  content.length =                  CalculateDurationSeconds(broadcast.starts_at, broadcast.stops_at)
  content.releaseDate =             FormatDateForDisplay(broadcast.starts_at)
  content.accountId =               ValidStr(broadcast.account_id)

  if broadcast.transcoder_profile = "720p"
      content.quality = true
  end if
  if broadcast.transcoder_profile = "1080p"
      content.fullHD = true
      content.hdBranded = true
  end if

  return content
end function

sub UpdateBroadcastViewMeta(broadcast)
  cfg = BoxCastConfig()

  url = cfg.apiRoot + "broadcasts/" + broadcast.id
  print "Getting broadcast from: ";url
  broadcastData = GetStringFromURL(url)
  jsonBroadcast = ParseJSON(broadcastData)
  if jsonBroadcast = invalid
    return
  end if

  ticketPrice = jsonBroadcast.ticket_price
  if ticketPrice = invalid
    ticketPrice = 0
  else if type(ticketPrice) = "String"
    ticketPrice = Val(ticketPrice)
  end if
  broadcast.addFields({ticketPrice: ticketPrice})

  url = cfg.apiRoot + "broadcasts/" + broadcast.id + "/view"
  print "Getting view from: ";url
  viewData = GetStringFromURL(url)
  jsonView = ParseJSON(viewData)
  if jsonView = invalid then
    return
  end if

  live = false
  if jsonView.status = "live"
    broadcast.live = true
  end if
  broadcast.addFields({live: live})

  broadcast.url = ValidStr(jsonView.playlist)
end sub

sub PostMetrics(action, data)
  cfg = BoxCastConfig()
  postString = ""
  if action = "setup"
    di = CreateObject("roDeviceInfo")
    ai = CreateObject("roAppInfo")
    data = ShallowCopy(data)
    data.user_agent = "Roku " + di.GetModel() + " " + di.GetVersion()
    data.platform = "Roku"
    data.browser_name = "Roku"
    data.player_version = "roku-" + ai.GetVersion()
    data.host = cfg.hostNameForAnalytics
  end if
  data.action = action
  data.timestamp = GetCurrentDateTimeString()
  postString = FormatJSON(data)
  print "Logging metrics to: ";cfg.metricsUrl;postString
  resp = PostDataToURL(cfg.metricsUrl, postString)
  print resp
end sub


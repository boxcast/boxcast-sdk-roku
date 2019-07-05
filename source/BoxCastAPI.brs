''
'' Retrieves information from the BoxCast API
''

function BoxCastAPI()
  this = {
    GetChannels: GetChannels
    GetBroadcastsForChannel: GetBroadcastsForChannel
    GetBroadcastById: GetBroadcastById
    UpdateBroadcastViewMeta: UpdateBroadcastViewMeta
    PostMetrics: PostMetrics
  }
  return this
end function

function GetChannels()
  cfg = BoxCastConfig()
  result = CreateObject("roSGNode", "ContentNode")

  c = CreateObject("roSGNode", "ContentNode")
  c.id = ValidStr(cfg.channelId)
  c.title = ValidStr("All Videos")
  result.appendChild(c)

  ' grabbing all the data for the playlist at once can result in a huge chunk of JSON
  ' and processing that into a BS structure can crash the box
  url = cfg.apiRoot + "accounts/" + cfg.accountId + "/channels?l=50"
  print "Getting channels from: ";url
  raw = GetStringFromURL(url)
  json = ParseJSON(raw)

  if json = invalid then
    return false
  end if

  for each channel in json
    c = CreateObject("roSGNode", "ContentNode")
    c.id = ValidStr(channel.id)
    c.title = ValidStr(channel.name)
    result.appendChild(c)
  next

  return result
end function

function GetBroadcastsForChannel(channelId, query)
  cfg = BoxCastConfig()
  result = CreateObject("roSGNode", "ContentNode")

  if query = invalid or query = "" then
    query = cfg.defaultChannelQueryString
  end if
  if channelId = invalid or channelId = "" then
    return false
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

  content.addFields({
    accountId: ValidStr(broadcast.account_id)
    timeframe: ValidStr(broadcast.timeframe)
    starts_at: ValidStr(broadcast.starts_at)
  })

  broadcast720 = CreateObject("roRegex", "^720p", "")
  if broadcast720.IsMatch(broadcast.transcoder_profile)
      content.quality = true
  end if
  broadcast1080 = CreateObject("roRegex", "^1080p", "")
  if broadcast1080.IsMatch(broadcast.transcoder_profile)
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

  broadcast.addFields({
    ticketPrice: ticketPrice,
    timeframe: jsonBroadcast.timeframe,
    starts_at: jsonBroadcast.starts_at
  })

  url = cfg.apiRoot + "broadcasts/" + broadcast.id + "/view"
  print "Getting view from: ";url
  viewData = GetStringFromURL(url)
  jsonView = ParseJSON(viewData)
  if jsonView = invalid then
    return
  end if

  content_settings = jsonView.settings
  broadcast.addFields({
    live: (jsonView.status = "live" or broadcast.timeframe = "current"),
    geoblock: (content_settings <> invalid and content_settings.geoblock <> invalid),
    cryptblock: (content_settings <> invalid and content_settings.cryptblock <> invalid),
  })

  broadcast.url = ValidStr(jsonView.playlist)
end sub

sub PostMetrics(action, data)
  MaxPossibleDurationSeconds = 60 * 60 * 24
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
  if data.duration <> invalid and data.duration > MaxPossibleDurationSeconds
    data.duration = MaxPossibleDurationSeconds
  end if
  postString = FormatJSON(data)
  print "Logging metrics to: ";cfg.metricsUrl;postString
  resp = PostDataToURL(cfg.metricsUrl, postString)
  print resp
end sub


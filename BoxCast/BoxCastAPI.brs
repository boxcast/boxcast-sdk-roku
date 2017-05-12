''
'' Retrieves information from the BoxCast API
''

function BoxCastAPI()
  this = {
    GetBroadcastsForChannel: GetBroadcastsForChannel
    UpdateBroadcastViewMeta: UpdateBroadcastViewMeta
    PostMetrics: PostMetrics
  }
  return this
end function

function GetBroadcastsForChannel(channelId)
  cfg = BoxCastConfig()
  result = []

  ' grabbing all the data for the playlist at once can result in a huge chunk of JSON
  ' and processing that into a BS structure can crash the box
  url = cfg.apiRoot + "channels/" + channelId + "/broadcasts?" + cfg.defaultChannelQueryString
  print "Getting videos for playlist from: ";url
  raw = GetStringFromURL(url)

  json = ParseJSON(raw)

  if json = invalid then
    return false
  end if

  for each broadcast in json
    'PrintAA(broadcast)
    transportAgnosticUrl = strReplace(broadcast.preview, "https", "http")

    ' https://sdkdocs.roku.com/display/sdkdoc/Content+Meta-Data
    newVid = {
      id:                      ValidStr(broadcast.id)
      contentId:               ValidStr(broadcast.id)
      name:                    ValidStr(broadcast.name)
      shortDescriptionLine1:   ValidStr(broadcast.name)
      shortDescriptionLine2:   Left(ValidStr(broadcast.description), 60)
      title:                   ValidStr(broadcast.name)
      description:             ValidStr(broadcast.description)
      synopsis:                ValidStr(broadcast.description)
      sdPosterURL:             ValidStr(broadcast.preview)
      hdPosterURL:             ValidStr(broadcast.preview)
      streams:                 []
      streamFormat:            "hls"
      contentType:             "episode"
      categories:              []
    }

    newVid.length = CalculateDurationSeconds(broadcast.starts_at, broadcast.stops_at)
    newVid.releaseDate = FormatDateForDisplay(broadcast.starts_at)

    if broadcast.transcoder_profile = "720p"
        newVid.quality = true
    end if
    if broadcast.transcoder_profile = "1080p"
        newVid.fullHD = true
        newVid.hdBranded = true
    end if

    result.Push(newVid)
  next

  return result
end function

sub UpdateBroadcastViewMeta(broadcast)
  ' grabbing all the data for the playlist at once can result in a huge chunk of
  ' JSON and processing that into a structure can crash the box
  cfg = BoxCastConfig()

  broadcastData = GetStringFromURL(cfg.apiRoot + "broadcasts/" + broadcast.id)
  jsonBroadcast = ParseJSON(broadcastData)
  if jsonBroadcast = invalid
    return
  end if
  broadcast.ticketPrice = jsonBroadcast.ticket_price
  if broadcast.ticketPrice = invalid
    broadcast.ticketPrice = 0
  else if type(broadcast.ticketPrice) = "String"
    broadcast.ticketPrice = Val(broadcast.ticketPrice)
  end if

  viewData = GetStringFromURL(cfg.apiRoot + "broadcasts/" + broadcast.id + "/view")
  jsonView = ParseJSON(viewData)
  if jsonView = invalid then
    return
  end if
  broadcast.streams.push({
    url: ValidStr(jsonView.playlist)
  })
  if jsonView.status = "live"
    broadcast.live = true
  else
    broadcast.live = false
  end if
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


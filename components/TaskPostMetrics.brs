sub Init()
  m.port = createObject("roMessagePort")
  m.top.functionName = "MainLoop"
  m.top.control = "RUN"
  m.top.observeField("params", m.port)
  m.cfg = BoxCastConfig()
  m.ViewerID = GetViewerID()
end sub

sub MainLoop()
  while true
    msg = wait(0, m.port)
    mt = type(msg)
    if msg.getField() = "params"
      processMetricsRequest(msg.getData())
    end if
  end while
end sub

'
' PRIVATE
'

sub processMetricsRequest(params)
  ? "TaskPostMetrics:processMetricsRequest: ";params
  broadcast = params.broadcast
  if params.action = "setup"
    m.metricsData = {
      is_live: broadcast.IsLive
      account_id: broadcast.AccountID
      broadcast_id: broadcast.ID
      channel_id: broadcast.ChannelID
      view_id: GetUniqueViewID()
      viewer_id: m.ViewerID
    }
    postMetrics(params.action, m.metricsData)
  else
    data = Utils_ShallowCopy(m.metricsData)
    data.duration = params.duration
    data.position = params.position
    postMetrics(params.action, data)
  end if
end sub

sub postMetrics(action, data)
  MaxPossibleDurationSeconds = 60 * 60 * 24
  cfg = BoxCastConfig()
  postString = ""

  if action = "setup"
    di = CreateObject("roDeviceInfo")
    ai = CreateObject("roAppInfo")
    data = Utils_ShallowCopy(data)
    data.user_agent = "Roku " + di.GetModel() + " " + di.GetVersion()
    data.platform = "Roku"
    data.browser_name = "Roku"
    data.player_version = "roku-" + ai.GetVersion()
    data.host = cfg.hostNameForAnalytics
  end if

  data.action = action
  data.timestamp = Utils_GetCurrentDateTimeString()
  if data.duration <> invalid and data.duration > MaxPossibleDurationSeconds
    data.duration = MaxPossibleDurationSeconds
  end if

  postString = FormatJSON(data)
  ? "Logging metrics to: ";cfg.metricsUrl;postString
  resp = postDataToURL(cfg.metricsUrl, postString)
  ? resp
end sub

function postDataToURL(url, body)
  result = ""
  timeout = 10000
  ut = CreateObject("roURLTransfer")
  ut.SetURL(url)
  ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
  ut.AddHeader("X-Roku-Reserved-Dev-Id", "")
  ut.InitClientCertificates()
  ut.SetPort(CreateObject("roMessagePort"))
  if ut.AsyncPostFromString(body)
    event = wait(timeout, ut.GetPort())
    if type(event) = "roUrlEvent"
      result = event.GetString()
    elseif event = invalid
      ut.AsyncCancel()
    endif
  end if
  return result
end function

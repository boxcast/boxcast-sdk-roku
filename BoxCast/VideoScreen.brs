'' Simple wrapper around roku-sdk/appVideoScreen

Function VideoScreen(broadcast As Object, channelId)
  print "Showing Video Screen";broadcast

  if broadcast.streams.Count() = 0
    BoxCastAPI().UpdateBroadcastViewMeta(broadcast)
  end if

  if broadcast.streams.Count() = 0 or broadcast.streams[0].url = ""
    print "No playlist is available for the broadcast"
    return -1
  end if

  if type(broadcast) <> "roAssociativeArray" then
    print "Invalid data passed to VideoScreen"
    return -1
  end if

  port = CreateObject("roMessagePort")
  screen = CreateObject("roVideoScreen")
  screen.SetMessagePort(port)
  screen.SetContent(broadcast)
  screen.SetPositionNotificationPeriod(60) 'Notify of time update every 60 seconds (for metrics capture)
  screen.Show()

  streamStarted = 0
  metricsData = {
    is_live: broadcast.live
    broadcast_id: broadcast.id
    channel_id: channelId
    view_id: GetUniqueViewID()
    viewer_id: GetViewerID()
  }
  PostMetrics("setup", metricsData)

  while true
    msg = wait(0, port)
    if type(msg) = "roVideoScreenEvent" then
      print "ShowVideoStream | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
      if msg.isScreenClosed()
        print "Exit video"
        exit while
      else if msg.isRequestFailed()
        print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
      else if msg.isStatusMessage()
        print "Video status: "; msg.GetIndex(); " " msg.GetData() 
      else if msg.isButtonPressed()
        print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
      elseif msg.isPlaybackPosition() then
        nowpos = msg.GetIndex()
        ' Keep track of where user is in registry for resuming
        RegWrite(broadcast.ContentId, nowpos.toStr())
        if streamStarted = 0
          ' Log message on initial playback
          PostMetrics("play", metricsData)
          streamStarted = GetCurrentDateTimeSeconds()
        else
          ' Log metrics about how long viewer has been watching
          duration = GetCurrentDateTimeSeconds() - streamStarted
          data = ShallowCopy(metricsData)
          data.duration = duration
          data.position = nowpos
          PostMetrics("timeupdate", data)
        end if
      else
        print "Unexpected event type: "; msg.GetType()
      end if
    else
      print "Unexpected message class: "; type(msg)
    end if
  end while

End Function


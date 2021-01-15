function OpenVideoPlayer(content as Object, index as Integer, isContentList as Boolean) as Object
  m.TaskPostMetrics = CreateObject("roSGNode", "TaskPostMetrics")

  video = CreateObject("roSGNode", "MediaView")

  video.content = content
  video.jumpToItem = index
  video.isContentList = isContentList
  video.control = "play"

  video.ObserveField("state", "OnVideoPlayerStateChange")
  video.ObserveField("position", "OnVideoPlayerPositionChange")

  m.top.ComponentController.CallFunc("show", {
    view: video
  })

  ' Start tracking metrics
  m.streamStarted = 0
  m.TaskPostMetrics.params = {
    action: "setup"
    broadcast: content
  }
  m.lastUpdatedMetrics = Utils_GetCurrentDateTimeSeconds()

  m.video = video
  return video
end function

sub OnVideoPlayerStateChange(event as Object)
  video = event.GetRoSGNode()
  ? "VideoPlayer:OnVideoPlayerStateChange: ";video.state
  position = video.position
  if video.state = "error"
    ? "Video error code: ";video.errorCode
    ? "Video error message: ";video.errorMsg
    m.video.close = true
  else if video.state = "playing"
    if m.streamStarted = 0
      m.TaskPostMetrics.params = {
        action: "play"
      }
      m.streamStarted = Utils_GetCurrentDateTimeSeconds()
      m.lastUpdatedMetrics = Utils_GetCurrentDateTimeSeconds()
    end if
  else if video.state = "paused"
    ensureStartPlayingSanity()
    duration = Utils_GetCurrentDateTimeSeconds() - m.streamStarted
    m.TaskPostMetrics.params = {
      action: "pause",
      duration: duration
    }
    m.lastUpdatedMetrics = Utils_GetCurrentDateTimeSeconds()
  else if video.state = "finished"
    ensureStartPlayingSanity()
    duration = Utils_GetCurrentDateTimeSeconds() - m.streamStarted
    m.TaskPostMetrics.params = {
      action: "complete"
      duration: duration
    }
  else if video.state = "buffering"
  else if video.state = "stopped"
  else if video.state = "paused"
  end if
end sub

sub OnVideoPlayerPositionChange(event as Object)
  video = event.GetRoSGNode()
  ' Post metrics every 60 seconds
  ensureStartPlayingSanity()
  if (Utils_GetCurrentDateTimeSeconds() - m.lastUpdatedMetrics) > 60
    position = video.position
    duration = Utils_GetCurrentDateTimeSeconds() - m.streamStarted
    m.TaskPostMetrics.params = {
      action: "timeupdate"
      duration: duration
      position: position
    }
    m.lastUpdatedMetrics = Utils_GetCurrentDateTimeSeconds()
  end if
end sub

'
' PRIVATE
'

sub ensureStartPlayingSanity()
  if m.streamStarted = 0
    m.streamStarted = Utils_GetCurrentDateTimeSeconds()
  end if
end sub

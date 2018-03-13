sub init()
  m.Image         = m.top.findNode("Image")
  m.Details       = m.top.findNode("Details")
  m.Title         = m.top.findNode("Title")
  m.Video         = m.top.findNode("Video")
  m.SpringDetails = m.top.findNode("SpringBoardDetails")
  m.LabelList     = m.top.findNode("LabelList")
  m.CategoryLabel = m.top.findNode("CategoryLabel")
  m.RuntimeLabel  = m.top.findNode("RuntimeLabel")
  m.Warning       = m.top.findNode("Warning")
  m.TaskPostMetrics = m.top.findNode("TaskPostMetrics")

  m.Video.ObserveField("state", "OnVideoPlayerStateChange")
  m.Video.ObserveField("position", "OnVideoPlayerPositionChange")

  m.Title.font.size = 40
  m.CategoryLabel.color = m.global.config.bodyFontPrimaryColor
  m.Title.color = m.global.config.bodyFontPrimaryColor
  m.Details.color = m.global.config.bodyFontSecondaryColor
  m.RuntimeLabel.color = m.global.config.bodyFontPrimaryColor
  m.LabelList.color = m.global.config.bodyFontPrimaryColor
  m.LabelList.focusedColor = m.global.config.bodyFontPrimaryColor
end sub

sub OnVideoPlayerStateChange()
  print "SpringBoard:OnVideoPlayerStateChange: ";m.Video.state
  position = m.Video.position
  if m.Video.state = "error"
    m.Video.visible = false
    print "Video error code: ";m.Video.errorCode
    print "Video error message: ";m.Video.errorMsg
    ShowWarning("There was an error playing back the video", "")
  else if m.Video.state = "playing"
    if m.streamStarted = 0
      m.TaskPostMetrics.params = {
        action: "play"
      }
      m.streamStarted = GetCurrentDateTimeSeconds()
      m.lastUpdatedMetrics = GetCurrentDateTimeSeconds()
    end if
  else if m.Video.state = "finished"
    duration = GetCurrentDateTimeSeconds() - m.streamStarted
    m.TaskPostMetrics.params = {
      action: "complete"
      duration: duration
    }
    m.video.visible = false
    m.SpringDetails.Visible=true
    m.LabelList.setFocus(true)
  else if m.Video.state = "buffering"
  else if m.Video.state = "stopped"
  else if m.Video.state = "paused"
  end if
end sub

sub OnVideoPlayerPositionChange()
  ' Post metrics every 60 seconds
  if (GetCurrentDateTimeSeconds() - m.lastUpdatedMetrics) > 60
    position = m.Video.position
    duration = GetCurrentDateTimeSeconds() - m.streamStarted
    m.TaskPostMetrics.params = {
      action: "timeupdate"
      duration: duration
      position: position
    }
    m.lastUpdatedMetrics = GetCurrentDateTimeSeconds()
  end if
end sub

sub ShowWarning(title, message)
  m.Warning.title = title
  m.Warning.message = message
  m.Warning.visible = true
end sub

sub onContentChange(event as object)
  content = event.getData()
  print "SpringBoard:onContentChange: "; content

  m.Warning.visible = false

  runtime = content.length
  minutes = runtime \ 60
  seconds = runtime MOD 60

  m.Image.uri = content.hdposterurl
  m.Title.text = content.title
  m.Details.text = content.description
  x = m.Details.localBoundingRect()
  m.RuntimeLabel.text = "Length: " + minutes.toStr() + " minutes " + seconds.toStr() + " seconds"
  translation = [m.RuntimeLabel.translation[0], m.Details.translation[1] + x.height + 30]
  m.RuntimeLabel.translation = translation

  m.content = content

  m.top.seekposition = m.global.BroadcastResumePositionCache[content.id]

  if content.ticketPrice > 0
    ShowWarning("Unable to play ticketed broadcast", "The BoxCast application for Roku does not allow playback of ticketed broadcasts at this time.")
    m.allowPlayback = false
    m.Video.content = invalid
    return
  else
    m.allowPlayback = true
  end if

  if IsNullOrEmpty(content.url)
    ShowWarning("Unable to play broadcast", "The video file could not be found")
    m.allowPlayback = false
    m.Video.content = invalid
    return
  else
    m.allowPlayback = true
  end if

  m.Video.content = content 'ContentNode

  if m.top.autoPlay
    PlayVideo(0)
  end if
end sub

sub onItemSelected(event as object)
  listItemIndex = event.getData()
  print "SpringBoard:onItemSelected: ";listItemIndex
  if listItemIndex <> 0
    PlayVideo(m.top.seekposition)
  else
    PlayVideo(0)
  end if
end sub

sub PlayVideo(seekPosition)
  if m.allowPlayback = false
    print "Playback is disallowed."
    return
  end if

  ' Play the video (either from beginning or resume position)
  m.Video.control = "play"
  if seekPosition <> 0
    print "Seeking to ";seekPosition
    m.Video.seek = seekPosition
  end if
  m.SpringDetails.visible = false
  m.Video.visible = true
  m.Video.setFocus(true)

  ' Start tracking metrics
  m.TaskPostMetrics.params = {
    action: "setup"
    broadcast: m.content
  }
  m.streamStarted = 0
  m.lastUpdatedMetrics = GetCurrentDateTimeSeconds()
end sub

' Called when a key on the remote is pressed
function onKeyEvent(key as String, press as Boolean) as Boolean
  print "SpringBoard:onKeyEvent: [";key;"][";press;"]"
  if press then
    if key = "back"
      if m.Video.visible
        m.Video.control = "pause"
        m.Video.visible = false
        m.SpringDetails.visible = true
        position = m.Video.position
        if position > 0
          if m.LabelList.content.getChildCount() > 1 then m.LabelList.content.removeChildIndex(1)
          minutes = position \ 60
          seconds = position MOD 60
          contentNode = createObject("roSGNode","ContentNode")
          contentNode.title = "Resume Video (" + minutes.toStr() + " min " + seconds.toStr() + " sec)"
          m.LabelList.content.appendChild(contentNode)
          m.global.TaskRegistry.write = {
            contentid: m.content.id
            position: position.toStr()
          }
          m.global.BroadcastResumePositionCache[m.content.id] = position.toStr()
          m.top.seekposition = position
        end if
        m.LabelList.setFocus(true)
        return true
      else
        return false
      end if
    else if m.Video.visible
      ' pressing around in video UI expecting controls to work.  make sure video has focus
      m.Video.setFocus(true)
    else if key = "OK"
    else
      return false
    end if
  end if
  return false
end function

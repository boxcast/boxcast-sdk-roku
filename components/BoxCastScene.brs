sub init()
  m.TaskRegistry = m.top.findNode("TaskRegistry")
  m.TaskRegistry.observeField("result", "onRegistryRead")
  AddAndSetFields(m.global, {TaskRegistry: m.TaskRegistry, BroadcastResumePositionCache: {}})

  m.TaskListBroadcasts = m.top.findNode("TaskListBroadcasts")
  m.TaskListBroadcasts.observeField("response", "onListBroadcasts")

  m.TaskGetBroadcast = m.top.findNode("TaskGetBroadcast")
  m.TaskGetBroadcast.observeField("response", "onGetBroadcast")

  m.ChannelList = m.top.findNode("ChannelList")
  m.ChannelList.observeField("ItemSelected", "onChannelListItemSelected")

  m.BroadcastList = m.top.findNode("BroadcastList")
  m.BroadcastList.observeField("ItemSelected", "onRowListItemSelected")

  m.SpringBoard = m.top.findNode("SpringBoard")
  m.SpringBoardLabelList = m.top.findNode("LabelList")
  m.Warning = m.top.findNode("Warning")

  ' Theme parameters
  m.ChannelList.rowLabelColor = m.global.config.bodyFontPrimaryColor
  m.BroadcastList.rowLabelColor = m.global.config.bodyFontPrimaryColor
  m.Rectangle = m.top.findNode("Rectangle")
  m.Rectangle.color = m.global.config.bodyBackgroundColor
  m.Overhang = m.top.findNode("Overhang")
  m.Overhang.color = m.global.config.overhangBackgroundColor
  m.Overhang.clockColor = m.global.config.overhangFontColor

  ' Init
  createChannelListContent()

  ' Check for content deep link
  args = m.global.mainArgs
  if args <> invalid and args.contentID <> invalid
    print "Requested deep link to: "; args.contentID
    m.autoPlay = true
    m.TaskGetBroadcast.params = {
      broadcastId: args.contentID
    }
  else
    m.autoPlay = false
    m.ChannelList.jumpToItem = 0
    onChannelListItemSelected({})
  end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  print "BoxCastScene::onKeyEvent ";key;" "; press
  if press then
    if m.Warning.visible
      ' Any key exits warning dialog
      hideWarningDialog()
      return true

    else if key = "back"
      if m.SpringBoard.visible
        m.SpringBoard.visible = false
        m.BroadcastList.visible = true
        m.ChannelList.visible = true
        m.BroadcastList.setFocus(true)
        return true
      else if m.ChannelList.hasFocus()
        ' support exit from app
        print "Closing app..."
        m.global.closeApp = true
        return true
      else if m.BroadcastList.visible
        'm.BroadcastList.visible = false
        m.ChannelList.visible = true
        m.ChannelList.setFocus(true)
        return true
      end if

    else if key = "left"
      if m.BroadcastList.visible then
        if m.BroadcastList.ItemFocused = 0 then
          m.ChannelList.visible = true
          m.ChannelList.setFocus(true)
          return true
        end if
      end if

    else if key = "right"
      if m.ChannelList.hasFocus()
        onChannelListItemSelected({})
      end if

    end if

  end if
  return false
end function

sub hideWarningDialog()
  m.Warning.visible = false
  m.BroadcastList.visible = false
  m.SpringBoard.visible = false
  m.ChannelList.visible = true
  m.ChannelList.setFocus(true)
end sub

sub onChannelListItemSelected(event as object)
  idx = m.ChannelList.ItemFocused
  channelObj = m.ChannelList.Content.getChild(idx)
  if channelObj = Invalid then
    return
  end if
  ' m.ChannelList.visible = false
  m.BroadcastList.visible = true
  ' Make API call to get the list of broadcasts...
  m.TaskListBroadcasts.params = {
    channel: channelObj.id
  }
end sub

sub createChannelListContent()
  print "createChannelListContent"
  m.ChannelList.visible = true
  m.ChannelList.setFocus(true)
  m.ChannelList.Content = m.global.channels
  print "created channellistcontent"; m.ChannelList.Content
end sub

sub onListBroadcasts(event as object)
  print "onListBroadcasts"
  listResponse = m.TaskListBroadcasts.response

  parentNode = createObject("roSGNode", "ContentNode")
  m.BroadcastListContent = []

  live = listResponse.live
  if live.getChild(0) <> invalid then
    live.title = "Live Broadcasts"
    parentNode.appendChild(live)
    m.BroadcastListContent.push(live)
  end if

  recent = listResponse.recent
  if recent.getChild(0) <> invalid then
    recent.title = "Recent Broadcasts"
    parentNode.appendChild(recent)
    m.BroadcastListContent.push(recent)
  end if

  if live.getChild(0) = invalid and recent.getChild(0) = invalid
    m.Warning.title = "No Broadcasts in Channel"
    m.Warning.message = "There are no broadcasts currently available in this channe. Press the back button to continue."
    m.Warning.visible = true
  end if

  m.BroadcastList.Content = parentNode
  m.BroadcastList.setFocus(true)
end sub

sub onRowListItemSelected(event as object)
  print "onRowListItemSelected";m.BroadcastList.RowItemSelected
  idx = m.BroadcastList.RowItemSelected
  broadcast = m.BroadcastListContent[idx[0]].getChild(idx[1])
  m.TaskGetBroadcast.params = {
    broadcast: broadcast
  }
  m.TaskRegistry.read = broadcast.id
end sub

sub onGetBroadcast(event as object)
  broadcastWithView = m.TaskGetBroadcast.response.broadcast
  if broadcastWithView = invalid
    print "Invalid broadcast; cannot continue"
    return
  end if
  print "onGetBroadcast"; broadcastWithView.id
  m.ChannelList.visible = false
  m.BroadcastList.visible = false
  m.SpringBoard.autoPlay = m.autoPlay
  m.autoPlay = false ' NOTE: only autoplay on initial launch with deep-link, then always take to springboard UI
  m.SpringBoard.visible = true
  m.SpringBoard.content = broadcastWithView
  if not m.autoPlay
    ' XXX: focus on the action list, not just the view
    ' Note that autoplay will focus on video element automatically
    m.SpringBoardLabelList.setFocus(true)
  end if
end sub

sub onRegistryRead(event as object)
  print "onRegistryRead: [";m.TaskRegistry.read;"][";m.TaskRegistry.result;"]"
  position = m.TaskRegistry.result.toFloat()
  cache = m.global.BroadcastResumePositionCache
  cache.AddReplace(m.TaskRegistry.read, position)
  m.global.BroadcastResumePositionCache = cache
  print "BroadcastResumePositionCache: ";m.global.BroadcastResumePositionCache
end sub


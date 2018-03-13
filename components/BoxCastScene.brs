sub init()
  m.TaskRegistry = m.top.findNode("TaskRegistry")
  m.TaskRegistry.observeField("result", "onRegistryRead")
  AddAndSetFields(m.global, {TaskRegistry: m.TaskRegistry, BroadcastResumePositionCache: {}})

  m.TaskListBroadcasts = m.top.findNode("TaskListBroadcasts")
  m.TaskListBroadcasts.observeField("response", "onListBroadcasts")

  m.TaskGetBroadcast = m.top.findNode("TaskGetBroadcast")
  m.TaskGetBroadcast.observeField("response", "onGetBroadcast")

  m.RowList = m.top.findNode("RowList")
  m.RowList.observeField("ItemSelected", "onRowListItemSelected")

  m.SpringBoard = m.top.findNode("SpringBoard")
  m.SpringBoardLabelList = m.top.findNode("LabelList")
  m.Warning = m.top.findNode("Warning")

  ' Theme parameters
  m.RowList.rowLabelColor = m.global.config.bodyFontPrimaryColor
  m.Rectangle = m.top.findNode("Rectangle")
  m.Rectangle.color = m.global.config.bodyBackgroundColor
  m.Overhang = m.top.findNode("Overhang")
  m.Overhang.color = m.global.config.bodyBackgroundColor
  m.Overhang.clockColor = m.global.config.bodyFontPrimaryColor

  ' Make first API call to get the list of broadcasts...
  m.TaskListBroadcasts.params = {
    channel: m.global.config.channelId
  }
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  print "BoxCastScene::onKeyEvent ";key;" "; press
  if press then
    if key = "options"

    else if key = "back"
      if m.Warning.visible
        m.Warning.visible = false
        return true
      else if m.SpringBoard.visible
        m.SpringBoard.visible = false
        m.RowList.visible = true
        m.RowList.setFocus(true)
        return true
      else
        return false
      end if

    else if key = "OK"
      if m.Warning.visible
        m.Warning.visible = false
        return true
      end if
    end if

  end if
  return false
end function

sub onListBroadcasts(event as object)
  print "onListBroadcasts"
  listResponse = m.TaskListBroadcasts.response

  parentNode = createObject("roSGNode", "ContentNode")
  m.RowListContent = []

  live = listResponse.live
  if live.getChild(0) <> invalid then
    live.title = "Live Broadcasts"
    parentNode.appendChild(live)
    m.RowListContent.push(live)
  end if

  recent = listResponse.recent
  if recent.getChild(0) <> invalid then
    recent.title = "Recent Broadcasts"
    parentNode.appendChild(recent)
    m.RowListContent.push(recent)
  end if

  m.RowList.Content = parentNode
  m.RowList.setFocus(true)

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
  end if
end sub

sub onRowListItemSelected(event as object)
  print "onRowListItemSelected";m.RowList.RowItemSelected
  idx = m.RowList.RowItemSelected
  broadcast = m.RowListContent[idx[0]].getChild(idx[1])
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
  m.RowList.visible = false
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


sub GetContent()
  account = m.top.HandlerConfig.account
  deepLinkContentID = m.top.HandlerConfig.deepLinkContentID
  channelID = account.ChannelID

  rootChildren = { children: [] }

  if deepLinkContentID <> invalid and deepLinkContentID <> ""
    soloRow = [GetBroadcast(deepLinkContentID)]
    rootChildren.children.Push({ title: "Selected Broadcast", children: soloRow })
  end if

  liveAndUpcoming = GetBroadcastsForChannel(channelID, "timeframe:preroll timeframe:current timeframe:future", "starts_at")
  if liveAndUpcoming.Count() > 0
    rootChildren.children.Push({ title: "Live and Upcoming", children: liveAndUpcoming})
  end if

  recent = GetBroadcastsForChannel(channelID, "timeframe:past", "-starts_at")
  if recent.Count() > 0
    rootChildren.children.Push({ title: "Recent Broadcasts", children: recent})
  end if

  m.top.content.Update(rootChildren)
  m.top.content.AddFields({"BoxCastLoadCompleted": true})
end sub

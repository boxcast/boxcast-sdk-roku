sub GetContent()
  broadcast = m.top.content
  view = GetBroadcastView(broadcast.ID, broadcast.ChannelID)
  restricted = isRestricted(broadcast, view)
  description = broadcast.description

  if restricted = true
    ? "Brodacast cannot be played as it is restricted"; broadcast
    description = "This broadcast is restricted and cannot be played on this device at this time."
  elseif hasValidPlaylist(view) <> true
    view.playlist = ""
    if broadcast.Timeframe = "past"
      ? "Past broadcast has no playlist available"; broadcast
      description = "The recording is not available."
    elseif broadcast.Timeframe = "current" or broadcast.Timeframe = "preroll"
      ? "Live broadcast has no playlist available"; broadcast
      description = "The broadcast is not yet streaming. Check back soon."
    else
      ? "Future broadcast cannot be played (as expected)"
    end if
  end if

  m.top.content.SetFields({
    Url:         view.playlist
    Description: description
  })

  m.top.content.AddFields({
    Loaded:       true
    IsRestricted: restricted
  })

  ? "Updated broadcast with view"; m.top.content; view.playlist
end sub

'
' PRIVATE
'

function hasValidPlaylist(view)
  if view.playlist = invalid or view.playlist = ""
    return false
  end if
  if view.status = invalid or view.status = ""
    return false
  end if
  if view.status.Instr("recorded") < 0 and view.status.Instr("live") < 0
    return false
  end if
  return true
end function

function isRestricted(broadcast, view)
  cs = view.settings
  if cs <> invalid and cs.geoblock <> invalid
    ? "Broadcast is geoblocked: "; cs.geoblock
    return true
  end if
  if cs <> invalid and cs.cryptblock <> invalid
    ? "Broadcast is password protected: "; cs.cryptblock
    return true
  end if
  if broadcast.TicketPrice <> invalid and broadcast.TicketPrice > 0
    ? "Broadcast is ticketed: "; broadcast.TicketPrice
  end if
  return false
end function

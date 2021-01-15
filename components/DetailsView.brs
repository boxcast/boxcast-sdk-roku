function ShowDetailsView(parentContent as Object, index as Integer) as Object
  details = CreateObject("roSGNode", "DetailsView")
  details.ObserveField("content", "OnDetailsContentSet")
  details.ObserveField("buttonSelected", "OnButtonSelected")

  ' Load the broadcast with the view as the content
  m.broadcast = parentContent.GetChild(index)

  ? "ShowDetailsView"
  ? m.broadcast

  content = m.broadcast.Clone(false)
  content.AddFields({
    HandlerConfigDetails: {
      name: "DetailsHandler",
      broadcastID: m.broadcast.ID
      channelID: m.broadcast.ChannelID
    }
  })

  details.SetFields({
    content: content
    jumpToItem: 0
    isContentList: false
    updateTheme: {
      Overhangtitle: content.Title
    }
  })

  m.top.ComponentController.CallFunc("show", {
    view: details
  })

  return details
end function

function OnDetailsContentSet(event as Object)
  details = event.GetRoSGNode()

  if details.content.Loaded = Invalid or details.content.Loaded <> true
    return false
  end if

  if details.content.IsRestricted = true
    ? "Brodacast cannot be played as it is restricted"; details.content
    newContent = m.broadcast.Clone(false)
    newContent.Description = "This broadcast is restricted and cannot be played on this device at this time."
    details.SetFields({
      content: newContent
      jumpToItem: 0
      isContentList: false
    })
  elseif details.content.URL = invalid or details.content.URL = ""
    ? "No playlist is available"
  else
    ? "Broadcast can be played"
    btnsContent = CreateObject("roSGNode", "ContentNode")
    btnsContent.Update({ children: [{ title: "Play", id: "play" }] })
    details.buttons = btnsContent
  end if

  if details.AutoPlay <> Invalid and details.AutoPlay = true
    ' Deep linking
    ? "AutoPlaying Video from deep link"
    OpenVideoPlayer(details.content, 0, false)
  end if

  return true
end function

sub OnButtonSelected(event as Object)
  details = event.GetRoSGNode()
  selectedButton = details.buttons.GetChild(event.GetData())

  if selectedButton.id = "play"
    OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
  end if
end sub

function ShowAccountView(parentContent as Object, index as Integer, deepLinkContentID as Object) as Object
  m.account = parentContent.GetChild(index)

  m.accountGrid = CreateObject("roSGNode", "GridView")
  m.accountGrid.ObserveField("rowItemSelected", "OnAccountGridItemSelected")
  m.accountGrid.ObserveField("content", "OnAccountGridContentSet")
  m.accountGrid.AddFields({DeepLinkContentID: deepLinkContentID})
  m.accountGrid.SetFields({
    style: "zoom"
    posterShape: "16x9"
  })

  m.lastRefresh = 0
  refreshAccountGridContentIfNecessary()

  CacheRecentlyViewedAccount(m.account.ID)

  m.top.ComponentController.CallFunc("show", {view: m.accountGrid})
  return m.accountGrid
end function

sub OnAccountGridContentSet(event as Object)
  grid = event.GetRoSGNode()
  if grid.content.BoxCastLoadCompleted <> true
    return
  end if
  if m.accountGrid.DeepLinkContentID = Invalid or m.accountGrid.DeepLinkContentID = ""
    return
  end if

  ? "Processing DeepLink"
  ' Make sure to only let this happen once
  m.accountGrid.RemoveField("DeepLinkContentID")

  ' Now show the details view and tell it to auto-play
  detailsView = ShowDetailsView(grid.content.GetChild(0), 0)
  detailsView.AddFields({"AutoPlay": true})
  detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

function OnAccountGridItemSelected(event as Object)
  grid = event.GetRoSGNode()
  selectedIndex = event.GetData()
  rowContent = grid.content.GetChild(selectedIndex[0])
  detailsView = ShowDetailsView(rowContent, selectedIndex[1])
  detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
  return true
end function

sub OnDetailsWasClosed(event as Object)
  refreshAccountGridContentIfNecessary()
end sub

'
' PRIVATE
'

sub refreshAccountGridContentIfNecessary()
  MinRefreshInterval = 60 ' 1 minute
  if (Utils_GetCurrentDateTimeSeconds() - m.lastRefresh) >= MinRefreshInterval
    m.lastRefresh = Utils_GetCurrentDateTimeSeconds()
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
      HandlerConfigGrid: {
        name: "AccountHandler"
        account: m.account
        deepLinkContentID: m.accountGrid.DeepLinkContentID
      }
    })
    m.accountGrid.content = content
  end if
end sub

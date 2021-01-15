' NOTE: we needed to update StandardGridItemComponent
' in components/SGDEX/Views/OtherNotes/ItemComponents/StandardGridItemComponent/...
' because there's no sane way to pass in a custom `itemComponentName` to the
' grid view, and we needed to display a LIVE badge on live items.

sub Show(args as Object)
  cfg = BoxCastConfig()
  account = mapAccountToContentNode(cfg.Account)
  content = CreateObject("roSGNode", "ContentNode")
  content.AppendChild(account)

  if args <> Invalid and args.contentId <> Invalid and args.mediaType <> Invalid
    ? "Requesting deep link via Show"
    ? args.contentId
    ? args.mediaType
  end if

  m.accountView = ShowAccountView(content, 0, args.contentId)
  m.accountView.ObserveField("wasClosed", "OnAccountWasClosed")
  m.top.signalBeacon("AppLaunchComplete")
end sub

' Handle deep linking with roInputEvent
sub Input(args as Object)
  if args <> Invalid and args.contentId <> Invalid and args.mediaType <> Invalid
    ? "Requesting deep link via Input"
    ? args.contentId
    ? args.mediaType
  end if
end sub

sub OnAccountWasClosed(event as Object)
end sub

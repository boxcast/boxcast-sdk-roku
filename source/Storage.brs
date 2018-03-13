' Utilities for interacting with local device storage.
' This includes persistent/semi-persistent viewer IDs
' as well as locally saved Favorite channels.

function GetViewerID()
  viewerId = RegRead("boxcast-viewer-id")
  if viewerId = invalid
    viewerId = GetUniqueViewID()
    RegWrite("boxcast-viewer-id", viewerId)
    return viewerId
  end if
  return viewerId
end function


function GetUniqueViewID()
  return GenerateGuid()
end function


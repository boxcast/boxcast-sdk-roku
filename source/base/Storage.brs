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

function GetRecentlyViewedAccountIDs()
  recentAccountIdCacheStr = RegRead("recent-accounts")
  if recentAccountIdCacheStr <> invalid
    return recentAccountIdCacheStr.Split(",")
  else
    return []
  end if
end function

function CacheRecentlyViewedAccount(accountId)
  cache = GetRecentlyViewedAccountIDs()

  ' First, if it's already here, just bump it up to newest slot
  for i = 0 to cache.Count()-1:
    if cache[i] = accountId
      cache.Delete(i)
      cache.Unshift(accountId)
      RegWrite("recent-accounts", cache.Join(","))
      return true
    end if
  next

  ' Otherwise make room and push this one at the front
  if cache.Count() >= 4
    cache.Delete(3)
  end if
  cache.Unshift(accountId)
  RegWrite("recent-accounts", cache.Join(","))
  return true
end function

function RegRead(key, section=invalid)
  if section = invalid then section = "Default"
  sec = CreateObject("roRegistrySection", section)
  if sec.Exists(key) then return sec.Read(key)
  return invalid
end function

function RegWrite(key, val, section=invalid)
  if section = invalid then section = "Default"
  sec = CreateObject("roRegistrySection", section)
  sec.Write(key, val)
  sec.Flush() 'commit it
end function

function GenerateGuid() As String
  ' Ex. 5EF8541E-C9F7-CFCD-4BD4-036AF6C145DA
  return GetRandomHexString(8) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(12)
end function

function GetRandomHexString(length As Integer) As String
  hexChars = "0123456789ABCDEF"
  hexString = ""
  for i = 1 to length
      hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
  next
  return hexString
end function

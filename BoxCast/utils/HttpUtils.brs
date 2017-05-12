'
' Calls the given URL and returns its result as a string.
' Modified from NWM_Utilities.brs in the Roku SDK
'

function GetStringFromURL(url)
 result = ""
 timeout = 10000

  ut = CreateObject("roURLTransfer")

  ' allow for https
  ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
  ut.AddHeader("X-Roku-Reserved-Dev-Id", "")
  ut.InitClientCertificates()

  ut.SetPort(CreateObject("roMessagePort"))
  ut.SetURL(url)
  if ut.AsyncGetToString()
    event = wait(timeout, ut.GetPort())
    if type(event) = "roUrlEvent"
      print ValidStr(event.GetResponseCode())
      result = event.GetString()
    elseif event = invalid
      ut.AsyncCancel()
      ' reset the connection on timeouts
      'ut = CreateURLTransferObject(url)
      'timeout = 2 * timeout
    else
      print "roUrlTransfer::AsyncGetToString(): unknown event"
    endif
  end if

  return result
end function


function PostDataToURL(url, body)
 result = ""
 timeout = 10000

  ut = CreateObject("roURLTransfer")

  ' allow for https
  ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
  ut.AddHeader("X-Roku-Reserved-Dev-Id", "")
  ut.InitClientCertificates()

  ut.SetPort(CreateObject("roMessagePort"))
  ut.SetURL(url)
  if ut.AsyncPostFromString(body)
    event = wait(timeout, ut.GetPort())
    if type(event) = "roUrlEvent"
      print ValidStr(event.GetResponseCode())
      result = event.GetString()
    elseif event = invalid
      ut.AsyncCancel()
      ' reset the connection on timeouts
      'ut = CreateURLTransferObject(url)
      'timeout = 2 * timeout
    else
      print "roUrlTransfer::AsyncGetToString(): unknown event"
    endif
  end if

  return result
end function

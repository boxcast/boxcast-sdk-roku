function GetAccountsByMarketContentItems()
  cfg = BoxCastConfig()
  url = CreateObject("roUrlTransfer")
  url.SetUrl(cfg.ApiRoot+"/shared_tv_accounts.json")
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.AddHeader("X-Roku-Reserved-Dev-Id", "")
  url.InitClientCertificates()
  feed = url.GetToString()

  churchAccounts = []
  sportsAccounts = []
  otherAccounts = []

  if feed.Len() > 0
    json = ParseJson(feed)
    if json <> invalid ' and json.rows <> invalid and json.rows.Count() > 0
      accounts = json.accounts
      for each account in accounts
        itemNode = mapAccountToContentNode(account)
        if account.market = "house-of-worship"
          churchAccounts.Push(itemNode)
        else if account.market = "college" or account.market = "high-school"
          sportsAccounts.Push(itemNode)
        else
          otherAccounts.Push(itemNode)
        end if
      end for
    end if
  end if

  return {
    church: churchAccounts
    sports: sportsAccounts
    other: otherAccounts
  }
end function

function GetLiveNowContentItems()
  cfg = BoxCastConfig()
  url = CreateObject("roUrlTransfer")
  url.SetUrl(cfg.apiRoot + "/shared_tv_accounts_live_now.json")
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.AddHeader("X-Roku-Reserved-Dev-Id", "")
  url.InitClientCertificates()
  feed = url.GetToString()

  broadcasts = []
  if feed.Len() > 0
    json = ParseJson(feed)
    if json <> invalid
      for each broadcast in json
        broadcasts.Push(mapBroadcastToContentNode(broadcast))
      end for
    end if
  end if
  return broadcasts
end function

function GetBroadcastsForChannel(channelId, query, sort)
  cfg = BoxCastConfig()
  url = CreateObject("roUrlTransfer")
  url.SetUrl(cfg.apiRoot + "/channels/" + channelID + "/broadcasts?l=50&q=" + url.Escape(query) + "&s=" + url.Escape(sort))
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.AddHeader("X-Roku-Reserved-Dev-Id", "")
  url.InitClientCertificates()
  feed = url.GetToString()

  broadcasts = []
  if feed.Len() > 0
    json = ParseJson(feed)
    if json <> invalid
      for each broadcast in json
        broadcasts.Push(mapBroadcastToContentNode(broadcast))
      end for
    end if
  end if
  return broadcasts
end function

function GetBroadcast(broadcastID)
  cfg = BoxCastConfig()
  url = CreateObject("roUrlTransfer")
  url.SetUrl(cfg.apiRoot + "/broadcasts/" + broadcastID)
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.AddHeader("X-Roku-Reserved-Dev-Id", "")
  url.InitClientCertificates()
  feed = url.GetToString()

  if feed.Len() > 0
    json = ParseJson(feed)
    if json <> invalid
      return mapBroadcastToContentNode(json)
    end if
  end if
  return {}
end function

function GetBroadcastView(broadcastID, channelID)
  cfg = BoxCastConfig()
  url = CreateObject("roUrlTransfer")
  url.SetUrl(cfg.apiRoot + "/broadcasts/" + broadcastID + "/view?channel_id=" + url.Escape(channelID))
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.AddHeader("X-Roku-Reserved-Dev-Id", "")
  url.InitClientCertificates()
  feed = url.GetToString()

  if feed.Len() > 0
    json = ParseJson(feed)
    if json <> invalid
      return json
    end if
  end if
  return {}
end function

'
' PRIVATE
'

function mapAccountToContentNode(account)
  itemNode = CreateObject("roSGNode", "ContentNode")
  Utils_ForceSetFields(itemNode, {
    Type:                  "account"
    ID:                    account.id
    Title:                 account.name
    Description:           account.description
    HDPosterURL:           proxyThroughImageResizer(account.thumb.src)
    Categories:            account.market
    ChannelID:             account.channel_id
    SearchText:            LCase(account.name) + " " + LCase(account.description)
    ShortDescriptionLine1: ""
    shortDescriptionLine2: account.name
  })
  return itemNode
end function

function mapBroadcastToContentNode(broadcast)
  itemNode = CreateObject("roSGNode", "ContentNode")
  shortDescriptionLine1 = ""
  isLive = false
  if broadcast.timeframe = "preroll"
    shortDescriptionLine1 = "ABOUT TO START"
    isLive = true
  else if broadcast.timeframe = "current"
    shortDescriptionLine1 = "LIVE"
    isLive = true
  else if broadcast.timeframe = "future"
    shortDescriptionLine1 = "Starts " + Utils_FormatDateForDisplay(broadcast.starts_at)
  end if
  preview = broadcast.preview
  if preview = ""
    preview = "pkg:/images/black.png"
  end if
  Utils_ForceSetFields(itemNode, {
    ' Standard Roku Content Attributes
    Title:                 broadcast.name
    Description:           broadcast.description
    HDPosterURL:           preview
    ReleaseDate:           Utils_FormatDateForDisplay(broadcast.starts_at)
    Length:                Utils_CalculateDurationSeconds(broadcast.starts_at, broadcast.stops_at)
    ShortDescriptionLine1: shortDescriptionLine1
    ShortDescriptionLine2: broadcast.name
    StreamFormat:          "hls"
    ContentType:           "episode"
    ' Custom Attributes
    ID:                    broadcast.id
    Type:                  "broadcast"
    ChannelID:             broadcast.channel_id
    AccountID:             broadcast.account_id
    AccountName:           broadcast.account_name
    IsLive:                isLive
    Timeframe:             broadcast.timeframe
    TicketPrice:           broadcast.ticket_price
    ' The `DetailsView` will use these other fields if we set them
    'Rating:                "PG-13"
    'Categories:            "category1, category2"
    'Actors:                "actor1, actor2"
  })
  return itemNode
end function

function proxyThroughImageResizer(url)
  cfg = BoxCastConfig()
  url = Utils_StrReplace(Utils_ValidStr(url), " ", "%20")
  url = Utils_StrReplace(url, "http://", "")
  url = Utils_StrReplace(url, "https://", "")
  url = Utils_StrReplace(url, "//", "")
  url = cfg.ImageResizeUrl + "/?url=" + url + "&w=300&h=169&t=letterbox&bg=black"
  return url
end function

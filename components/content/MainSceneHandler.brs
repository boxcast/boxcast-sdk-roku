sub GetContent()
  accounts = GetAccountsByMarketContentItems()
  liveNow = GetLiveNowContentItems()

  rootChildren = {
    children: [
      ' Placeholder row for custom actions (e.g. search, favorites, etc.)
      { title: "", children: getCustomActionContentItems(accounts) }
    ]
  }

  ' Row for live now
  if liveNow.Count() > 0
    rootChildren.children.Push({ title: "Live Now", children: liveNow})
  end if

  ' One row per market
  cfg = BoxCastConfig()
  if accounts.church.Count() > 0
    rootChildren.children.Push({ title: cfg.GroupedRowPrefix+" House of Worship", children: accounts.church})
  end if
  if accounts.sports.Count() > 0
    rootChildren.children.Push({ title: cfg.GroupedRowPrefix+" Sports", children: accounts.sports})
  end if
  if accounts.other.Count() > 0
    rootChildren.children.Push({ title: cfg.GroupedRowPrefix+" Other", children: accounts.other})
  end if

  m.top.content.Update(rootChildren)
end sub

'
' PRIVATE
'

function getCustomActionContentItems(accounts)
  results = []

  ' Search
  n1 = CreateObject("roSGNode", "ContentNode")
  Utils_ForceSetFields(n1, {
    ID: "__search__", Title: "Find a Broadcaster", HDPosterURL: "pkg:/images/search.png"
  })
  results.Push(n1)

  ' Recently viewed accounts
  accountIDs = GetRecentlyViewedAccountIDs()
  for each accountID in accountIDs
    account = getAccountByID(accountID, accounts)
    if account <> invalid
      results.Push(account.Clone(false))
    end if
  next

  return results
end function

function getAccountByID(accountID, accounts)
  for each category in ["church", "sports", "other"]
    for each account in accounts[category]
      if account.ID = accountID
        return account
      end if
    next
  next
  return invalid
end function

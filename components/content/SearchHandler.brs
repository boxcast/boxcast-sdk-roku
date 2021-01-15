sub GetContent()
  query = m.top.query
  ? "searching for: "; lcase(query)

  ' Accounts are initialized in the RootHandler
  accounts = m.top.content.AllAccounts
  ? "starting with "; accounts.Count(); " accounts"

  re = CreateObject("roRegex", LCase(query), "i")

  results = []
  for i = 0 to accounts.Count() - 1
    account = accounts[i]
    if re.IsMatch(account.SearchText) = true
      results.Push(account)
    end if
  next

  ? "found "; results.Count(); " matching accounts"

  rootChildren = {children: [{title: "", children: results}]}
  m.top.content.Update(rootChildren)
end sub

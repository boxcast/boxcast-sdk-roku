function ShowSearchView(rootAccountContent)
  searchView = CreateObject("roSGNode", "SearchView")
  searchView.hintText = "Search for a broadcaster..."
  searchView.SetFields({
    updateTheme: {
      Overhangtitle: "Find a Broadcaster"
    }
  })

  m.allAccounts = getContentFromRoot(rootAccountContent)

  searchView.ObserveFieldScoped("query", "OnSearchQuery")
  searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")

  m.top.ComponentController.CallFunc("show", {
    view: searchView
  })

  return searchView
end function

sub OnSearchQuery(event as Object)
  query = event.GetData()
  searchView = event.GetRoSGNode()

  content = CreateObject("roSGNode", "ContentNode")

  ' perform search if user has typed at least three characters
  if query.Len() > 2
    content.AddFields({
      AllAccounts: m.allAccounts
      HandlerConfigSearch: {
        name: "SearchHandler"
        query: query
      }
    })
  end if

  ' setting the content with handlerConfigSearch will create
  ' the content handler where search should be performed
  ' setting the clear content node or invalid will clear the grid with results
  searchView.content = content
end sub

sub OnSearchItemSelected(event as Object)
  ? "Item selected = " ; event.GetData()
  grid = event.GetRoSGNode()
  selectedIndex = event.GetData()
  rowContent = grid.content.GetChild(selectedIndex[0])

  ShowAccountView(rowContent, selectedIndex[1])
end sub

'
' PRIVATE
'

function getContentFromRoot(rootAccountContent)
  ' Undo the grouping from the RootHandler.brs
  cfg = BoxCastConfig()
  content = []
  for each row in rootAccountContent.GetChildren(-1, 0)
    if row.title.Left(6) = cfg.GroupedRowPrefix
      for each account in row.GetChildren(-1, 0)
        content.Push(account.Clone(false))
      end for
    end if
  end for
  content.SortBy("Title")
  return content
end function

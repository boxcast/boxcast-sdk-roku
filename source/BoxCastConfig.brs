Function BoxCastConfig() As Object
  this = {
    HostNameForAnalytics: "BoxCast.tv for Roku"
    ApiRoot:              "https://api.boxcast.com"
    MetricsUrl:           "https://metrics.boxcast.com/player/interaction"
    ImageResizeUrl:       "https://images.weserv.nl"
    GroupedRowPrefix:     "Browse"

    ' Custom TV App Requirements
    Theme: {
      OverhangLogoUri:  "pkg:/images/logo.png"
      OverhangTitle:    ""
      BackgroundColor:  "#336699"
      AccentColor:      "#CCCCCC"
    }

    Account: {
      id:           "DEMOAMYR"
      name:         "Testing"
      description:  ""
      thumb:        {src: ""}
      market:       ""
      channel_id:   "JLp4ZFFDfDgCKWEpXIk5"
    }
  }
  return this

End Function

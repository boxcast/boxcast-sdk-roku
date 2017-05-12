Function BoxCastConfig() As Object
  this = {
    ' Edit for your application
    channelId: ""
    hostNameForAnalytics: "BoxCast.tv for Roku"

    ' Can leave as default
    defaultChannelQueryString: "q=timeframe%3Arelevant&s=-starts_at&l=20"
    apiRoot: "https://api.boxcast.com/"
    metricsUrl: "https://metrics.boxcast.com/player/interaction"
  }
  return this

End Function

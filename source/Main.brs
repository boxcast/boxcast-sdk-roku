sub Main(args as Dynamic)
  cfg = BoxCastConfig()
  api = BoxCastAPI()

  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("BoxCastScene")
  m.global = screen.getGlobalNode()
  m.global.addFields({
    mainArgs: args,
    config: cfg,
    channels: api.GetChannels(),
    closeApp: false
  })
  screen.show()

  while(true)
    msg = wait(500, m.port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent" and msg.isScreenClosed()
      return
    end if
    if m.global.closeApp = true
      return
    end if
  end while
end sub

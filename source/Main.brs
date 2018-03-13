sub Main(args as Dynamic)
  cfg = BoxCastConfig()

  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("BoxCastScene")
  m.global = screen.getGlobalNode()
  m.global.addFields({
    mainArgs: args,
    config: cfg
  })
  screen.show()

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while
end sub

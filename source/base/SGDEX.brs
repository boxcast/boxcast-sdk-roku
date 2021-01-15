sub RunUserInterface(args)
  m.args = args
  if Type(GetSceneName) <> "<uninitialized>" AND GetSceneName <> invalid AND GetInterface(GetSceneName, "ifFunction") <> invalid then
    StartSGDEXChannel(GetSceneName(), args)
  else
    ? "Error: SGDEX, please implement 'GetSceneName() as String' function and return name of your scene that is extended from BaseScene"
  end if
end sub

sub StartSGDEXChannel(componentName, args)
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.SetMessagePort(m.port)
  scene = screen.CreateScene(componentName)
  screen.Show()
  scene.ObserveField("exitChannel", m.port)
  scene.launch_args = args

  ' Customize theme
  ' https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/5-Themes_Guide.md
  cfg = BoxCastConfig()
  scene.theme = {
    global: {
      OverhangLogoUri:                  cfg.Theme.OverhangLogoUri
      OverhangTitle:                    cfg.Theme.OverhangTitle
      OverhangShowClock:                true
      OverhangShowOptions:              false
      BackgroundColor:                  cfg.Theme.BackgroundColor
      progressBarColor:                 cfg.Theme.AccentColor
      bufferingBarFilledBarBlendColor:  cfg.Theme.AccentColor
      retrievingBarFilledBarBlendColor: cfg.Theme.AccentColor
      itemTextBackgroundColor:          "0x000000"
    }
  }

  ' create roInput context for handling roInputEvent messages
  input = CreateObject("roInput")
  input.setMessagePort(m.port)

  while (true)
    msg = Wait(0, m.port)
    msgType = Type(msg)
    if msgType = "roSGScreenEvent"
      if msg.IsScreenClosed() then return
    else if msgType = "roSGNodeEvent"
      field = msg.getField()
      data = msg.getData()
      if field = "exitChannel" and data = true
        END
      end if
    else if msgType = "roInputEvent"
      ' roInputEvent deep linking, pass arguments to the scene
      scene.input_args = msg.getInfo()
    end if
  end while
end sub

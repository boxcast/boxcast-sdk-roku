<a href="https://www.boxcast.com" target="_blank"><img src="https://www.boxcast.com/hs-fs/hub/484866/file-2483746126-png/Logos/NewBoxCastLogo.png?t=1494524438771" height="25"></a>&nbsp;<a href="https://developer.roku.com" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/en/6/6c/Roku_logo_white_on_purple.jpg" height="25"></a>

# boxcast-sdk-roku

The [BoxCast](https://www.boxcast.com) SDK for Roku video playback allows you to develop your own Roku applications to watch content from your BoxCast account.

The SDK provides a set of [BrightScript](https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Language+Reference) utilities for querying data from your account and a set of [SceneGraph](https://sdkdocs.roku.com/display/sdkdoc/SceneGraph+Core+Concepts) components for building your UI.

## Installation

```
git clone https://github.com/boxcast/boxcast-sdk-roku.git
```

Copy the `source` and `components` directories into your Roku project (or include as a git subtree/submodule).

## Usage

Edit the `source/BoxCastConfig.brs` to match your settings
```vb
this = {
    accountId: ' TODO: fill in from dashboard '
    channelId: ' TODO: fill in from dashboard '
    hostNameForAnalytics: ' TODO: unique identifier used for analytics '
    ...
}
```

The Main.brs and BoxCastScene components are enough to bootstrap an entire application. Ensure the SpringBoard and Video player are attached per the examples in order to provide viewer analytics back to your BoxCast account. Individual
utlilites can be sprinkled throughout an existing application, e.g.:
```vb
cfg = BoxCastConfig()
api = BoxCastAPI()
```

List broadcasts, to be displayed in your scene.
```vb
broadcasts = api.GetBroadcastsForChannel(cfg.channelId)
```

Before publishing, make sure to also update the `manifest` and `Makefile` with your app name and settings.

## Known Limitations

* This SDK is for viewing and querying of broadcasts on accounts that do not protect their content with pay-per-view ticketing, host restrictions, geoblocking, passwords, or other authentication means.  The BoxCast API will reject requests for such content, so you should be prepared to handle errors.

## Changelog

### v2.3.2 on 2019-06-21

* Add sample Makefile and manifest for managing the app

### v2.3.1 on 2019-03-08

* Better handling of quality level and timeframe #2

### v2.3.0 on 2018-08-31

* Fix issue with analytics reporting unreasonably large view durations

### v2.2.0 on 2018-08-24

* Fix issue where ticket price was not being properly set, in some cases resulting in an app crash.

### v2.1.0 on 2018-08-09

* Fixes bug where analytics were not properly reported (thanks to Perry Brown for tracking this down).

### v2.0.0 on 2018-03-13

* Application skeleton is now based on SceneGraph framework

### v2.0.0 on 2018-03-13

* Application skeleton is now based on SceneGraph framework

### v1.0.0 on 2017-05-12

* Initial version

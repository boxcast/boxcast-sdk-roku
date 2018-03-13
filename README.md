<a href="https://www.boxcast.com" target="_blank"><img src="https://www.boxcast.com/hs-fs/hub/484866/file-2483746126-png/Logos/NewBoxCastLogo.png?t=1494524438771" height="25"></a>&nbsp;<a href="https://developer.roku.com" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/en/6/6c/Roku_logo_white_on_purple.jpg" height="25"></a>

# boxcast-sdk-roku

The [BoxCast](https://www.boxcast.com) SDK for Roku video playback allows you to develop your own Roku applications to watch content from your BoxCast account.

The SDK provides a set of [BrightScript](https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Language+Reference) utilities for querying data from your account and a set of [SceneGraph](https://sdkdocs.roku.com/display/sdkdoc/SceneGraph+Core+Concepts) component, including a SpringBoard and Video player that provide viewer analytics back to your BoxCast account.

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

The Main.brs and BoxCastScene components are enough to bootstrap an entire application.  Individual
utlilites can be sprinkled throughout an existing application, e.g.:
```vb
cfg = BoxCastConfig()
api = BoxCastAPI()
```

List broadcasts, to be displayed in your scene.
```vb
broadcasts = api.GetBroadcastsForChannel(cfg.channelId)
```

## Known Limitations

* The `VideoScreen` component uses the `roVideoScreen` and `roVideoScreenEvent` components, which have been deprecated and replaced by SceneGraph equivalents.  This is scheduled to be updated in the next release of the BoxCast SDK for Roku.
* This SDK is for viewing and querying of broadcasts on accounts that do not protect their content with pay-per-view ticketing, host restrictions, geoblocking, passwords, or other authentication means.  The BoxCast API will reject requests for such content, so you should be prepared to handle errors.

## Changelog

* v2.0.0 (2018-03-13): Application skeleton is now based on SceneGraph framework
* v1.0.0 (2017-05-12): Initial version

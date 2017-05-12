<a href="https://www.boxcast.com" target="_blank"><img src="https://www.boxcast.com/hs-fs/hub/484866/file-2483746126-png/Logos/NewBoxCastLogo.png?t=1494524438771" height="25"></a>&nbsp;<a href="https://developer.roku.com" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/en/6/6c/Roku_logo_white_on_purple.jpg" height="25"></a>

# boxcast-sdk-roku

The [BoxCast](https://www.boxcast.com) SDK for Roku video playback allows you to develop your own Roku applications to watch content from your BoxCast account.

The SDK provides a set of [BrightScript](https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Language+Reference) utilities for querying data from your account and a method of attaching to a native [Video](https://sdkdocs.roku.com/display/sdkdoc/Video) element in order to provide viewer analytics back to your BoxCast account.

## Installation

```
git clone https://github.com/boxcast/boxcast-sdk-roku.git
```

Copy the `BoxCast` directory into your project source (or include as a git subtree/submodule).

## Usage

Edit the `BoxCast/BoxCastConfig.brs` to match your settings
```vb
this = {
    channelId: ' TODO: fill in from dashboard '
    hostNameForAnalytics: ' TODO: unique identifier used for analytics '
    ...
}
```

Initialize utilities.
```vb
cfg = BoxCastConfig()
api = BoxCastAPI()
```

List broadcasts, to be displayed in your scene.
```vb
broadcasts = api.GetBroadcastsForChannel(cfg.channelId)
```



When ready to watch a broadcast, simply initialize a VideoScreen component for the broadcast, which will request the playlist from the BoxCast API and present a native player.
```vb
VideoScreen(broadcast, cfg.channelId)
```

## Known Limitations

* This SDK is for viewing and querying of broadcasts on accounts that do not protect their content with pay-per-view ticketing, host restrictions, geoblocking, passwords, or other authentication means.  The BoxCast API will reject requests for such content, so you should be prepared to handle errors.

## Changelog

* v1.0.0: Initial version

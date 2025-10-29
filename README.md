<a href="https://www.boxcast.com" target="_blank"><img src="https://www.boxcast.com/hs-fs/hub/484866/file-2483746126-png/Logos/NewBoxCastLogo.png?t=1494524438771" height="25"></a> &nbsp; <a href="https://developer.roku.com" target="_blank"><img src="https://image.roku.com/bWFya2V0aW5n/roku-logo.png" height="25"></a>

# boxcast-sdk-roku

**This repository is no longer being maintained or supported. Please use at your own risk.**

The [BoxCast](https://www.boxcast.com) SDK for Roku video playback allows you to develop your own Roku applications to watch content from your BoxCast account.

This repository provides an entire sample application, built with a combination of the following Roku technologies:
* [BrightScript](https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Language+Reference) utilities for querying data from your account and tracking viewer analytics
* [SGDEX](https://github.com/rokudev/SceneGraphDeveloperExtensions) components that can be extended to customize your viewer's experience

## Installation

```
git clone https://github.com/boxcast/boxcast-sdk-roku.git
```

## Usage

Edit the `source/BoxCastConfig.brs` to match your settings. The most important
fields that _must_ be filled in are your Account ID and Channel ID, which can be
found on your
<a href="https://dashboard.boxcast.com/settings/my-account" target="_blank">Dashboard Settings</a>.

```vb
this = {
  ...

  Account: {
    id:         ' TODO: fill in from dashboard '
    channel_id: ' TODO: fill in from dashboard '
  }

  ...
}
```

Then follow <a href="https://developer.roku.com/docs/developer-program/getting-started/roku-dev-prog.md" target="_blank">
standard Roku Development practices</a>.  Note that there is a Makefile that
includes a `make install` script for easily bundling and installing your
application on your Roku device, provided that you set up an environment
variable for `ROKU_DEV_TARGET` and `DEVPASSWORD`.

Before publishing, make sure to also update the `manifest` and `Makefile` with your app
name and settings, as well as configuring your own images.

## Known Limitations

* This SDK is for viewing and querying of broadcasts on accounts that do not protect their content with pay-per-view ticketing, host restrictions, geoblocking, passwords, or other authentication means.  The BoxCast API will reject requests for such content, so you should be prepared to handle errors.

## SGDEX License

SceneGraph Developer Extensions (SGDEX) and associated documentation files (the "Software") are Copyright (c) 2019 Roku, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

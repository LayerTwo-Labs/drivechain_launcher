# Drivechain Launcher

🚧 Under construction

This application is built using [Godot](https://github.com/godotengine/godot).

Godot may seem like an odd choice at first glance, but with its cross-platform
abilities and an amazing set of GUI & IO features, it makes it very capable for
this application.

We can currently run on Mac, Windows, and Linux.

If you'd like to build from source, check below.

## Development Environment Prerequisites

- Godot 4.2.1 [Download Page](https://godotengine.org/download)

```bash
# macOS
$ brew install godot

# Ubuntu/Debian
$ snap install godot-4 # note: this gets installed as godot-4, not godot

# Windows
$ choco install godot
```

## Getting started

Ensure that `godot` is installed such that is in on your `$PATH`.

For building releases, so-called "export templates" has to be downloaded. These
are available from the official
[website](https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_export_templates.tpz).
Note that these are unique per version of Godot, but _not_ unique per platform
we're exporting for.

From the GUI, these templates can be downloaded like this:

1. "Project" menu in the toolbar
2. "Export" item within the "Project" menu
3. "Manage Export Templates"
4. "Download and Install"

## Important

The app relies on external binaries to be downloaded from a specific GitHub
release. This is a bit cumbersome, but was the best we could come up with for
now.

- chain_providers.cfg are where each of the sidechain configs starts. The hash
  and file size for each platform binary is manually generated and added to the
  config for the release if it has changed.
- version.cfg is where you would update the version and base GitHub release URL.
  Sometimes you may need to create a pre-release, upload all the binaries there
  and point to that as you are developing.
- Currently, each platform version is built on its respective platform. So build
  the launcher for Linux on Linux, Mac on Mac, and Windows on Windows.
- Mac is a bit different as you need to have a developer ID certificate so that
  Godot can request a signature and notarization. Whoever does this will need to
  create a signing certificate request and have Paul then create a new developer
  ID certificate with that request. Then you would install that into your Mac
  keychain. More info here:
  https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates

## Export preset notes

The file `export_presets.cfg` controls the export (i.e. build) process for the
Launcher. It is controlled through the Godot GUI. If you write comments in the
file, they will get **erased** once the file is saved. Furthermore, enums are
represented as numbers, not strings...

`export_presets.cfg` is kept in Git. This file does not contain anything
sensitive. It is _merged_ with `.godot/export_credentials.cfg`, which _does_
contain sensitive information. This file is also merged with certain environment
variables, such that this can be done on CI without fiddling around with files.

### macOS

Signing (and therefore also notarizing) the application requires having the
correct set of certificates + private keys on the machine doing the export.
Certificates can be viewed using `Keychain Access.app`. Seeing certificates
capable of signing (i.e. certificates with private keys):

```bash
$ security find-identity -v -p codesigning | grep LayerTwo`
```

Notarizing the app requires an App Store Connect API key. Docs for generating
this can be found
[here](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api).
There's three components to this key, which should go into
`.godot/export_credentials.cfg` before exporting:

1. Issuer ID (`notarization/api_uuid`). This is an UUID indicating which
   organization the key belongs to. This is available over the
   [list of active keys](https://appstoreconnect.apple.com/access/integrations/api).
2. The key itself (`notarization/api_key`). This is a path to a `.p8` file, and
   can only be obtained when creating the key.
3. Key ID (`notarization/api_key_id`). This is available in the
   [list of active keys](https://appstoreconnect.apple.com/access/integrations/api).

Explanation of export config file options:

```
export/distribution_type
0=testing ?
1=distribution
2=app store

codesign/codesign
0=disabled
1=built-in ad-hoc
2=rcodesign ruby tool for exporting from Linux
3=Xcode codesign

notarization/notarization
0=disabled
2=xcrun notarytool
```

Generate App Store Connect API keys:

Download the key somewhere

Docs on macOS:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html

### Windows

Signing (is that the correct Windows nomenclature?) of the build artifacts does
not happen in our pipeline. This leads to a scary pop-up warning the user when
they try and launch the app. This could probably be set up, somehow. Left as an
exercise to the reader!

## LICENSE

MIT License

Copyright (c) 2023 Layer Two Labs

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

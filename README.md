# Drivechain Launcher

🚧 Under construction

This application is built using [Godot](https://github.com/godotengine/godot)

Godot may seem like an odd choice at first glance, but with its cross-platform abilities and an amazing set of GUI &
IO features, it makes it very capabile for this application. 

We can currently run on Mac, Windows and Linux.

If you'd like to build from source check below.

## Development Enviornment Prerequisites

- Godot 4.1.1 [Download Page](https://godotengine.org/download)

Currently only scripted in GDScript, but we could use the .NET version of Godot which brings C# support

Once you've gotten your development environment setup

- Clone repo
- Open the project and run

### Important

The app relies on external binaries to be downloaded from specific github release. This is a bit combersome,
but was the best we could come up with for now.

- chain_providers.cfg are where each of the sidechain configs start.
	The hash and file size for each platform binary is manually generated and added to the config
	for the release if it has changed.
- version.cfg is where you would update the version and base github release url.
	Sometimes you may need to create a pre-release, upload all the binaries there and point to that
	as you are developing.
- Currently each platform version is built on its respective platform. So build the launcher for linux on linux,
	Mac on mac, and Windows on Windows.
- Mac is a bit different as you need to have a developer ID certificate so that Godot can request signature and
	notarization. Whom ever does this will need to create a signing certificate request and have Paul then create a
	new developer ID certificate with that request. Then you would install that into you mac keychain.
	More info here: https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates

### LICENSE

MIT License

Copyright (c) 2023 Layer Two Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

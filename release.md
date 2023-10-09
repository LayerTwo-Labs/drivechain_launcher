Drivechain Launcher is an experimental application that allows you to easily run BIP300 enabled sidechains easily in regtest mode. It's currently under heavy development and is only intended for testing purposes at this time.

## Release Notes for v1.1.0

- Added zSide for linux
- Added Bitnames for all platforms
- Updated Thunder for all platforms
- Launcher now defaults to using OpenGL for renderer

## Updating Instructions

If you still have previous launchers installed you will need to go into settings and select "Reset Everything". This works for Linux and Mac, but due to weirdness on Windows you may need to directly delete the **drivechain_launcher** directory which is located at: **C:\Users\<your user>\AppData\Roaming\drivechain_launcher**

## Launcher Downloads

- **[Linux](https://github.com/LayerTwo-Labs/drivechain_launcher/releases/download/v1.1.0/drivechain_launcher-linux-1.1.0.x86_64.tar.gz)**

Linux Zip hash: **9d49bcf6962219b106c152455a7fa1567eb0b1574e906ce4ea3d1a2d753e1509**

- **[MacOS](https://github.com/LayerTwo-Labs/drivechain_launcher/releases/download/v1.1.0/drivechain_launcher-osx64-1.1.0.dmg.zip)**

MacOS Zip hash: **cab04182c58c6162e47dd920e06ff2a1db795aeb0c93e03e9f12db95963835da**

- **[Windows](https://github.com/LayerTwo-Labs/drivechain_launcher/releases/download/v1.1.0/drivechain_launcher-1.1.0-win.zip)**

Windows Zip hash: **da2c7705a3d8b4921d9a0e64d65b879df5f38f852330defc4bb54dbd22f1239f**

## Run Instructions

To run on linux, untar and run from terminal:

```
./drivechain_launcher_linux-1.1.0.x86_64
```

To run on macOS, unzip and mount the .dmg file:

```
Depending on your macOS version, its possible that GateKeeper will not allow you to run the launcher.
We are working on notarizing the macOS build so that this isnt a problem.
```

To run on Windows, unzip and run the .exe

## Help

If you have any trouble, the first thing to do is go to settings and select "Reset Everything". If things are still not working as expected, you can try removing the **drivechain_launcher** folder which is located at:

```
Linux: ~/.local/share/drivechain_launcher
Win: C:/Users/<your_user>/AppData/Roaming/drivechain_launcher
Mac: ~/Library/Application Support/drivechain_launcher
```

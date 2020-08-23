# PearDrop

🍐 A cross-platform file transfer application

[![Discuss On Discord][discord]][discord-url]
[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues]][issues-url]

These days, closed ecosystems surround us. iPhones only share with Apple devices, Android phones only with Windows. Sending a file from one place to another is difficult and frustrating, usually requiring you to send an email to yourself. This is not acceptable, and PearDrop aims to solve this issue. PearDrop is an application built on a custom protocol that is available on every platform (Apple, Google, Windows, etc). This allows for simple and efficient file transfer when you really need it.

## Gallery

<img src="https://user-images.githubusercontent.com/47064842/90986562-ef697900-e551-11ea-8146-78d8e82dad67.gif" width="30%"></img> <img src="https://user-images.githubusercontent.com/47064842/90986585-08722a00-e552-11ea-80e3-cf213545837e.gif" width="30%"></img> <img src="https://user-images.githubusercontent.com/47064842/90986522-913c9600-e551-11ea-9462-200fb640da95.jpg" width="30%"></img>

## Installation

`iOS:` Via the App Store or [Testflight](https://testflight.apple.com/join/jnlYfhfP) for the latest version

`Android:` Via the [Google Play Store](https://play.google.com/store/apps/details?id=com.mr.flutter.plugin.peardrop_flutter&hl=en_US)

`Windows:` Clone this repo, ensure you are on the latest flutter `dev` release with `flutter channel dev`, then run

```
flutter pub get

cd peardrop_flutter

flutter run -d windows
```

There will be a new `PearDrop.exe` file under `peardrop_flutter/build/windows` for you to run

`MacOS:` Same as Windows, except run `flutter run` targeting macos

`Linux:` Coming soon...

If you run into issues when building for desktop, try running `flutter doctor`

## How it works

PearDrop is an app built on Flutter, a framework that enables cross-platform compatibility for a single codebase. It uses a one-page layout with the following UI/UX flow:

`Open App or Click On Share Sheet/Taskbar => Select File to Share => Select Device to Share To`

Once a device has been clicked on, it will initiate a function that displays a modal panel to the receiving device asking them to accept or decline. If the transmission was accepted, it will share the file to the other device. The sharing user can then select another device to send to, or click on the file button to select a different file to send.

For more information on how PearDrop works visit the [wiki](https://github.com/GoldinGuy/PearDrop/wiki), which describes [Architecture](https://github.com/GoldinGuy/PearDrop/wiki/Architecture), [Core Format](https://github.com/GoldinGuy/PearDrop/wiki/Core-format), and [Network Extensions](https://github.com/GoldinGuy/PearDrop/wiki/Network-extensions) in detail

## Development setup

Simply clone the repository, then run

```
flutter pub get
```

Then to test the app, enter the `peardrop_flutter` directory and run

```
cd peardrop_flutter

flutter devices

flutter run -d "target device"
```

## Contributing

1. Fork PearDrop [here](https://github.com/GoldinGuy/PearDrop/fork)
2. Create a feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

## Meta

Created by Students [@GoldinGuy](https://github.com/GoldinGuy) and [@anirudhb](https://github.com/anirudhb)

Distributed under the GNU AGPLv3 license. See [LICENSE](https://github.com/GoldinGuy/PearDrop/blob/master/LICENSE) for more information.

<!-- Markdown link & img dfn's -->

[discord-url]: https://discord.gg/gKYSMeJ
[discord]: https://img.shields.io/discord/689176425701703810
[issues]: https://img.shields.io/github/issues/GoldinGuy/PearDrop
[issues-url]: https://github.com/GoldinGuy/PearDrop/issues
[contributors-shield]: https://img.shields.io/github/contributors/GoldinGuy/PearDrop.svg?style=flat-square
[contributors-url]: https://github.com/GoldinGuy/PearDrop/graphs/contributors

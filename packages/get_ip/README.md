# get_ip

Helps you acquire the IP address of the user's device. (Works on Android & iOS)

Simply use this:

```dart
String ipAddress = await GetIp.ipAddress;
```

You need to import the package:

```dart
import 'package:get_ip/get_ip.dart';
```

And on Android you need to add these permissions:

```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Please report all bugs :)

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

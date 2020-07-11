# multicast_lock

Flutter plugin adding ability to access [MulticastLock](https://developer.android.com/reference/android/net/wifi/WifiManager.MulticastLock) which is required for receiving broadcast and multicast UDP packets

## Example code

pubspec.yaml:
```yaml
...
dependencies:
  multicast_lock: any
```


example dart code:
```dart
import 'package:multicast_lock/multicast_lock.dart';


void main() {
  final multicastLock = new MulticastLock();
  multicastLock.acquire();
  
  // example listener code
  final socket = await RawDatagramSocket.bind('224.0.0.1', 1900);
  socket.multicastHops = 10;
  socket.broadcastEnabled = true;
  socket.writeEventsEnabled = true;
  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagramPacket = _socket.receive();
      if (datagramPacket == null) return;

      print("packet!");
      print(datagramPacket);
    }});
  
  
  // ...
  // we should release lock after listening
  multicastLock.release();
}

```
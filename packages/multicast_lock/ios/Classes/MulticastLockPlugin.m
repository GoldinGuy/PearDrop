#import "MulticastLockPlugin.h"

@implementation MulticastLockPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"multicast_lock"
            binaryMessenger:[registrar messenger]];
  MulticastLockPlugin* instance = [[MulticastLockPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(true);
}

@end

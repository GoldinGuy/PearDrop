#import "GetIpPlugin.h"
#if __has_include(<get_ip/get_ip-Swift.h>)
#import <get_ip/get_ip-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "get_ip-Swift.h"
#endif

@implementation GetIpPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGetIpPlugin registerWithRegistrar:registrar];
}
@end

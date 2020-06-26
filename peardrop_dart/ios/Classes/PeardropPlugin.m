#import "PeardropPlugin.h"
#if __has_include(<peardrop/peardrop-Swift.h>)
#import <peardrop/peardrop-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "peardrop-Swift.h"
#endif

@implementation PeardropPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPeardropPlugin registerWithRegistrar:registrar];
}
@end

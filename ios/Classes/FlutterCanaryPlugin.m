#import "FlutterCanaryPlugin.h"
#if __has_include(<flutter_canary/flutter_canary-Swift.h>)
#import <flutter_canary/flutter_canary-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_canary-Swift.h"
#endif

@implementation FlutterCanaryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCanaryPlugin registerWithRegistrar:registrar];
}
@end

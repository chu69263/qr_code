#import "QrCodePlugin.h"
#if __has_include(<qr_code/qr_code-Swift.h>)
#import <qr_code/qr_code-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qr_code-Swift.h"
#endif

@implementation QrCodePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQrCodePlugin registerWithRegistrar:registrar];
}
@end

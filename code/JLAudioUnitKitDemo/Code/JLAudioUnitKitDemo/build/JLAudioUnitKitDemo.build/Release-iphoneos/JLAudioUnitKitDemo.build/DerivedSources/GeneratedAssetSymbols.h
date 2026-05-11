#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.zh-jieli.JLAudioUnitKitDemo";

/// The "bgColor" asset catalog color resource.
static NSString * const ACColorNameBgColor AC_SWIFT_PRIVATE = @"bgColor";

/// The "fontBackText_90" asset catalog color resource.
static NSString * const ACColorNameFontBackText90 AC_SWIFT_PRIVATE = @"fontBackText_90";

/// The "themeColor" asset catalog color resource.
static NSString * const ACColorNameThemeColor AC_SWIFT_PRIVATE = @"themeColor";

/// The "icon_return" asset catalog image resource.
static NSString * const ACImageNameIconReturn AC_SWIFT_PRIVATE = @"icon_return";

#undef AC_SWIFT_PRIVATE

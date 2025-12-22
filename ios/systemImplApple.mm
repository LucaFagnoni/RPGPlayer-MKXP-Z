// systemImplApple.mm - iOS-compatible version
// Patches for iOS: AppKit->UIKit, isMetalSupported for iOS
// Place this in ios/ directory to override the macOS-specific version

#import <TargetConditionals.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#else
#import <AppKit/AppKit.h>
#import <Metal/Metal.h>
#endif

#include "system/system.h"
#include <string>

namespace systemImpl {

std::string getSystemLanguage() {
    @autoreleasepool {
        NSArray *languages = [NSLocale preferredLanguages];
        if (languages.count > 0) {
            NSString *lang = languages[0];
            return std::string([lang UTF8String]);
        }
        return "en";
    }
}

std::string getUserName() {
    @autoreleasepool {
#if TARGET_OS_IOS
        return "User";
#else
        return std::string([NSUserName() UTF8String]);
#endif
    }
}

int getScalingFactor() {
    @autoreleasepool {
#if TARGET_OS_IOS
        return (int)[[UIScreen mainScreen] scale];
#else
        return (int)[[NSScreen mainScreen] backingScaleFactor];
#endif
    }
}

bool isWine() {
    return false;
}

bool isRosetta() {
    return false;
}

WineHostType getRealHostType() {
#if TARGET_OS_IOS
    return Mac; // Close enough for iOS
#elif defined(__APPLE__)
    return Mac;
#else
    return Linux;
#endif
}

} // namespace systemImpl

#ifdef MKXPZ_BUILD_XCODE

std::string getPlistValue(const char *key) {
    @autoreleasepool {
        NSString *nsKey = [NSString stringWithUTF8String:key];
        id value = [[NSBundle mainBundle] objectForInfoDictionaryKey:nsKey];
        if ([value isKindOfClass:[NSString class]]) {
            return std::string([value UTF8String]);
        }
        return "";
    }
}

void openSettingsWindow() {
    // No settings window on iOS (handled by iOS Settings app)
}

bool isMetalSupported() {
    @autoreleasepool {
        // Check if Metal is available
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        return device != nil;
    }
}

#endif // MKXPZ_BUILD_XCODE

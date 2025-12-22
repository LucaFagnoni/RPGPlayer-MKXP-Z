//
//  filesystemImplApple-ios.mm
//  mkxp-z iOS
//
//  iOS-specific implementation of filesystemImpl functions
//  This replaces the macOS version that uses AppKit
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <SDL_filesystem.h>

#import "filesystemImpl.h"
#import "util/exception.h"

#define PATHTONS(str) [NSFileManager.defaultManager stringWithFileSystemRepresentation:str length:strlen(str)]

#define NSTOPATH(str) [NSFileManager.defaultManager fileSystemRepresentationWithPath:str]

bool filesystemImpl::fileExists(const char *path) {
    @autoreleasepool{
        BOOL isDir;
        return [NSFileManager.defaultManager fileExistsAtPath:PATHTONS(path) isDirectory: &isDir] && !isDir;
    }
}

std::string filesystemImpl::contentsOfFileAsString(const char *path) {
    @autoreleasepool {
        NSString *fileContents = [NSString stringWithContentsOfFile: PATHTONS(path) encoding:NSUTF8StringEncoding error:nil];
        if (fileContents == nil)
            throw Exception(Exception::NoFileError, "Failed to read file at %s", path);
        
        return std::string(fileContents.UTF8String);
    }
}

bool filesystemImpl::setCurrentDirectory(const char *path) {
    @autoreleasepool {
        return [NSFileManager.defaultManager changeCurrentDirectoryPath: PATHTONS(path)];
    }
}

std::string filesystemImpl::getCurrentDirectory() {
    @autoreleasepool {
        return std::string(NSTOPATH(NSFileManager.defaultManager.currentDirectoryPath));
    }
}

std::string filesystemImpl::normalizePath(const char *path, bool preferred, bool absolute) {
    @autoreleasepool {
        // For relative paths like "Data/Scripts.rxdata", don't convert to absolute
        NSString *inputPath = PATHTONS(path);
        
        // Check if it's already a relative path (doesn't start with /)
        if (![inputPath hasPrefix:@"/"]) {
            // It's relative - just normalize slashes and return as-is
            NSString *normalized = [inputPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            return std::string(NSTOPATH(normalized));
        }
        
        // For absolute paths, do the full normalization
        NSString *nspath = [NSURL fileURLWithPath:inputPath].URLByStandardizingPath.path;
        
        if (!absolute) {
            // Get CWD and also standardize it (to handle /private/var vs /var symlinks)
            NSString *pwd = NSFileManager.defaultManager.currentDirectoryPath;
            NSString *pwdStandardized = [NSURL fileURLWithPath:pwd].URLByStandardizingPath.path;
            NSString *pwdWithSlash = [NSString stringWithFormat:@"%@/", pwdStandardized];
            
            // Try to make it relative to CWD
            if ([nspath hasPrefix:pwdWithSlash]) {
                nspath = [nspath substringFromIndex:pwdWithSlash.length];
            }
        }
        
        nspath = [nspath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        return std::string(NSTOPATH(nspath));
    }
}

std::string filesystemImpl::getDefaultGameRoot() {
    @autoreleasepool {
        // On iOS, the game root is typically the Documents/Games folder
        // For now, return the bundle's main resource path
        return std::string(NSTOPATH(NSBundle.mainBundle.resourcePath));
    }
}

// Helper function to find assets
static NSString *getPathForAsset_internal(const char *baseName, const char *ext) {
    // On iOS, assets may be in the main bundle resources
    @autoreleasepool {
        if (!baseName || baseName[0] == '\0') {
            return nil;
        }
        
        NSString *nsBaseName = [NSString stringWithUTF8String:baseName];
        NSString *nsExt = (ext && ext[0] != '\0') ? [NSString stringWithUTF8String:ext] : nil;
        
        // Check if baseName contains a directory path (e.g., "Shaders/minimal")
        NSString *directory = nil;
        NSString *resourceName = nsBaseName;
        
        NSRange lastSlash = [nsBaseName rangeOfString:@"/" options:NSBackwardsSearch];
        if (lastSlash.location != NSNotFound) {
            // Split into directory and filename
            directory = [nsBaseName substringToIndex:lastSlash.location];
            resourceName = [nsBaseName substringFromIndex:lastSlash.location + 1];
        }
        
        // Try main bundle first
        NSString *path = nil;
        if (directory) {
            path = [[NSBundle mainBundle] pathForResource:resourceName ofType:nsExt inDirectory:directory];
        } else {
            path = [[NSBundle mainBundle] pathForResource:resourceName ofType:nsExt];
        }
        if (path) {
            return path;
        }
        
        // Try Assets.bundle
        NSBundle *assetBundle = [NSBundle bundleWithPath:
                                 [NSString stringWithFormat:@"%@/Assets.bundle",
                                  NSBundle.mainBundle.resourcePath]];
        if (assetBundle) {
            if (directory) {
                path = [assetBundle pathForResource:resourceName ofType:nsExt inDirectory:directory];
            } else {
                path = [assetBundle pathForResource:resourceName ofType:nsExt];
            }
            if (path) {
                return path;
            }
        }
        
        return nil;
    }
}

std::string filesystemImpl::getPathForAsset(const char *baseName, const char *ext) {
    @autoreleasepool {
        NSString *assetPath = getPathForAsset_internal(baseName, ext);
        
        // On iOS, we don't throw exception for missing assets
        // Some assets may simply not exist and that's OK
        if (assetPath == nil) {
            fprintf(stderr, "[filesystemImpl] Warning: Could not find asset %s.%s\n", 
                    baseName ? baseName : "(null)", ext ? ext : "(null)");
            return "";
        }
        
        return std::string(NSTOPATH(assetPath));
    }
}

std::string filesystemImpl::contentsOfAssetAsString(const char *baseName, const char *ext) {
    @autoreleasepool {
        NSString *path = getPathForAsset_internal(baseName, ext);
        if (path == nil) {
            throw Exception(Exception::NoFileError, "Failed to find asset %s.%s", baseName, ext);
        }
        
        NSString *fileContents = [NSString stringWithContentsOfFile:path 
                                                           encoding:NSUTF8StringEncoding 
                                                              error:nil];
        
        if (fileContents == nil)
            throw Exception(Exception::MKXPError, "Failed to read file at %s", path.UTF8String);
        
        return std::string(fileContents.UTF8String);
    }
}

std::string filesystemImpl::getResourcePath() {
    @autoreleasepool {
        return std::string(NSTOPATH(NSBundle.mainBundle.resourcePath));
    }
}

// On iOS, this is not applicable (no NSOpenPanel)
std::string filesystemImpl::selectPath(SDL_Window *win, const char *msg, const char *prompt) {
    // iOS doesn't have native file dialogs like macOS
    // Would need UIDocumentPickerViewController for this
    return "";
}

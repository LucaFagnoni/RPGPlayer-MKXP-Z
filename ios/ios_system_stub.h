// binding-mri-ios-patch.h - iOS patches for binding-mri.cpp
// This file provides iOS-compatible replacements for unavailable functions

#ifndef BINDING_MRI_IOS_PATCH_H
#define BINDING_MRI_IOS_PATCH_H

#ifdef IOS_PLATFORM

// On iOS, std::system is unavailable. Provide a compile-time workaround
// by creating a namespace-scoped replacement function that returns error.
namespace ios_compat {
    inline int system_stub(const char *) { return -1; }
}

// Macro to replace std::system in specific files
// This only affects local usages, not system headers
#define IOS_SYSTEM_CALL(cmd) (ios_compat::system_stub(cmd))

#else

#define IOS_SYSTEM_CALL(cmd) (std::system(cmd))

#endif // IOS_PLATFORM

#endif // BINDING_MRI_IOS_PATCH_H

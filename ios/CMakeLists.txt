# MKXP-Z iOS Build Configuration
# CMakeLists.txt for cross-compiling MKXP-Z engine for iOS
# Use with: cmake -DCMAKE_TOOLCHAIN_FILE=../../deps/ios_toolchain.cmake -G Xcode ..
cmake_minimum_required(VERSION 3.20)

project(mkxp-z-ios VERSION 2.4.2 LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ====================
# Configuration
# ====================

# Path to pre-built iOS dependencies
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../deps/ios_dist")

# Platform detection for device vs simulator
if(CMAKE_OSX_SYSROOT MATCHES "iphonesimulator")
    set(IOS_PLATFORM "SIMULATOR")
    set(RUBY_LIB_DIR "${DEPS_DIR}/lib/simulator")
else()
    set(IOS_PLATFORM "DEVICE")
    set(RUBY_LIB_DIR "${DEPS_DIR}/lib/device")
endif()

message(STATUS "MKXP-Z iOS Build")
message(STATUS "  Platform: ${IOS_PLATFORM}")
message(STATUS "  Dependencies: ${DEPS_DIR}")

# ====================
# Build Definitions
# ====================

add_compile_definitions(
    MKXPZ_VERSION="${PROJECT_VERSION}"
    MKXPZ_BUILD_CMAKE
    MKXPZ_BUILD_XCODE  # Enables Apple platform-specific code
    MKXPZ_ALCDEVICE=ALCdevice
    AL_LIBTYPE_STATIC
    GLES2_HEADER
    HAVE_NANOSLEEP
    IOS_PLATFORM
    MKXPZ_MINIFFI  # Enable Win32API module
    _TTF_Font=TTF_Font  # SDL_ttf3 compatibility: maps MKXP-Z's _TTF_Font to TTF_Font
    MKXPZ_NO_SYSTEM_CALL  # Disable std::system() calls on iOS
)

# ====================
# Include Directories
# ====================

set(MKXPZ_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src")
set(MKXPZ_BINDING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../binding")
set(MKXPZ_SHADER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../shader")
set(MKXPZ_ASSETS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../assets")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}  # iOS-specific stubs (TouchBar.h)
    ${CMAKE_CURRENT_SOURCE_DIR}/generated  # Generated xxd headers
    ${CMAKE_CURRENT_SOURCE_DIR}/..  # For 'src/util/util.h' style includes
    ${MKXPZ_SRC_DIR}
    ${MKXPZ_SRC_DIR}/audio
    ${MKXPZ_SRC_DIR}/crypto
    ${MKXPZ_SRC_DIR}/display
    ${MKXPZ_SRC_DIR}/display/gl
    ${MKXPZ_SRC_DIR}/display/libnsgif
    ${MKXPZ_SRC_DIR}/display/libnsgif/utils
    ${MKXPZ_SRC_DIR}/etc
    ${MKXPZ_SRC_DIR}/filesystem
    ${MKXPZ_SRC_DIR}/filesystem/ghc
    ${MKXPZ_SRC_DIR}/input
    ${MKXPZ_SRC_DIR}/net
    ${MKXPZ_SRC_DIR}/system
    ${MKXPZ_SRC_DIR}/util
    ${MKXPZ_SRC_DIR}/util/sigslot
    ${MKXPZ_SRC_DIR}/util/sigslot/adapter
    ${MKXPZ_SRC_DIR}/theoraplay
    ${MKXPZ_BINDING_DIR}
    # Dependencies
    ${DEPS_DIR}/include
    ${DEPS_DIR}/include/AL   # OpenAL headers
    ${DEPS_DIR}/include/SDL2
    ${DEPS_DIR}/include/pixman-1  # pixman.h
    ${DEPS_DIR}/include/freetype2  # ft2build.h
    ${DEPS_DIR}/include/uchardet
    ${DEPS_DIR}/include/ruby-4.0.0+0
    ${DEPS_DIR}/include/ruby-4.0.0+0/aarch64-ios  # iOS-specific Ruby config.h
)

# ====================
# Source Files
# ====================

set(MKXPZ_SOURCES
    # Core
    ${MKXPZ_SRC_DIR}/main.cpp
    ${MKXPZ_SRC_DIR}/config.cpp
    ${MKXPZ_SRC_DIR}/eventthread.cpp
    ${MKXPZ_SRC_DIR}/settingsmenu.cpp
    ${MKXPZ_SRC_DIR}/sharedstate.cpp
    
    # Audio
    ${MKXPZ_SRC_DIR}/audio/alstream.cpp
    ${MKXPZ_SRC_DIR}/audio/audio.cpp
    ${MKXPZ_SRC_DIR}/audio/audiostream.cpp
    ${MKXPZ_SRC_DIR}/audio/fluid-fun.cpp
    ${MKXPZ_SRC_DIR}/audio/midisource.cpp
    ${MKXPZ_SRC_DIR}/audio/sdlsoundsource.cpp
    ${MKXPZ_SRC_DIR}/audio/soundemitter.cpp
    ${MKXPZ_SRC_DIR}/audio/vorbissource.cpp
    ${MKXPZ_SRC_DIR}/theoraplay/theoraplay.c
    
    # Crypto
    ${MKXPZ_SRC_DIR}/crypto/rgssad.cpp
    
    # Display
    ${MKXPZ_SRC_DIR}/display/autotiles.cpp
    ${MKXPZ_SRC_DIR}/display/autotilesvx.cpp
    ${MKXPZ_SRC_DIR}/display/bitmap.cpp
    ${MKXPZ_SRC_DIR}/display/font.cpp
    ${MKXPZ_SRC_DIR}/display/graphics.cpp
    ${MKXPZ_SRC_DIR}/display/plane.cpp
    ${MKXPZ_SRC_DIR}/display/sprite.cpp
    ${MKXPZ_SRC_DIR}/display/tilemap.cpp
    ${MKXPZ_SRC_DIR}/display/tilemapvx.cpp
    ${MKXPZ_SRC_DIR}/display/viewport.cpp
    ${MKXPZ_SRC_DIR}/display/window.cpp
    ${MKXPZ_SRC_DIR}/display/windowvx.cpp
    ${MKXPZ_SRC_DIR}/display/libnsgif/libnsgif.c
    ${MKXPZ_SRC_DIR}/display/libnsgif/lzw.c
    
    # OpenGL
    ${MKXPZ_SRC_DIR}/display/gl/gl-debug.cpp
    ${MKXPZ_SRC_DIR}/display/gl/gl-fun.cpp
    ${MKXPZ_SRC_DIR}/display/gl/gl-meta.cpp
    ${MKXPZ_SRC_DIR}/display/gl/glstate.cpp
    ${MKXPZ_SRC_DIR}/display/gl/scene.cpp
    ${MKXPZ_SRC_DIR}/display/gl/shader.cpp
    ${MKXPZ_SRC_DIR}/display/gl/texpool.cpp
    ${MKXPZ_SRC_DIR}/display/gl/tileatlas.cpp
    ${MKXPZ_SRC_DIR}/display/gl/tileatlasvx.cpp
    ${MKXPZ_SRC_DIR}/display/gl/tilequad.cpp
    ${MKXPZ_SRC_DIR}/display/gl/vertex.cpp
    
    # Utilities
    ${MKXPZ_SRC_DIR}/util/iniconfig.cpp
    ${MKXPZ_SRC_DIR}/util/win-consoleutils.cpp
    
    # Etc
    ${MKXPZ_SRC_DIR}/etc/etc.cpp
    ${MKXPZ_SRC_DIR}/etc/table.cpp
    
    # Filesystem
    ${MKXPZ_SRC_DIR}/filesystem/filesystem.cpp
    ${MKXPZ_SRC_DIR}/filesystem/filesystemImpl.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/filesystemImplApple-ios.mm  # iOS-specific Apple implementation
    
    # Input
    ${MKXPZ_SRC_DIR}/input/input.cpp
    ${MKXPZ_SRC_DIR}/input/keybindings.cpp
    
    # Network
    ${MKXPZ_SRC_DIR}/net/LUrlParser.cpp
    ${MKXPZ_SRC_DIR}/net/net.cpp
    
    # System (use iOS-specific version)
    ${MKXPZ_SRC_DIR}/system/systemImpl.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/systemImplApple.mm  # iOS-compatible version
    
    # Ruby Bindings (use iOS-patched version for binding-mri)
    ${CMAKE_CURRENT_SOURCE_DIR}/binding-mri-ios.cpp  # Patched for iOS std::system unavailability
    ${MKXPZ_BINDING_DIR}/binding-util.cpp
    ${MKXPZ_BINDING_DIR}/table-binding.cpp
    ${MKXPZ_BINDING_DIR}/etc-binding.cpp
    ${MKXPZ_BINDING_DIR}/bitmap-binding.cpp
    ${MKXPZ_BINDING_DIR}/font-binding.cpp
    ${MKXPZ_BINDING_DIR}/graphics-binding.cpp
    ${MKXPZ_BINDING_DIR}/input-binding.cpp
    ${MKXPZ_BINDING_DIR}/sprite-binding.cpp
    ${MKXPZ_BINDING_DIR}/viewport-binding.cpp
    ${MKXPZ_BINDING_DIR}/plane-binding.cpp
    ${MKXPZ_BINDING_DIR}/window-binding.cpp
    ${MKXPZ_BINDING_DIR}/tilemap-binding.cpp
    ${MKXPZ_BINDING_DIR}/audio-binding.cpp
    ${MKXPZ_BINDING_DIR}/module_rpg.cpp
    ${MKXPZ_BINDING_DIR}/filesystem-binding.cpp
    ${MKXPZ_BINDING_DIR}/windowvx-binding.cpp
    ${MKXPZ_BINDING_DIR}/tilemapvx-binding.cpp
    ${MKXPZ_BINDING_DIR}/http-binding.cpp
    ${MKXPZ_BINDING_DIR}/miniffi-binding.cpp
    ${MKXPZ_BINDING_DIR}/miniffi.cpp
)

# ====================
# Libraries
# ====================

set(LIB_DIR "${DEPS_DIR}/lib")

# Direct links to the custom cross-compiled static iOS libraries
set(SDL2_LIB "${LIB_DIR}/libSDL2.a")
set(SDL2_IMAGE_LIB "${LIB_DIR}/libSDL2_image.a")
set(SDL2_TTF_LIB "${LIB_DIR}/libSDL2_ttf.a")
set(SDL2_SOUND_LIB "${LIB_DIR}/libSDL2_sound.a")
set(OGG_LIB "${LIB_DIR}/libogg.a")
set(VORBIS_LIB "${LIB_DIR}/libvorbis.a")
set(VORBISFILE_LIB "${LIB_DIR}/libvorbisfile.a")
set(THEORA_LIB "${LIB_DIR}/libtheora.a")
set(THEORADEC_LIB "${LIB_DIR}/libtheoradec.a")
set(OPENAL_LIB "${LIB_DIR}/libopenal.a")
set(PHYSFS_LIB "${LIB_DIR}/libphysfs.a")
set(PIXMAN_LIB "${LIB_DIR}/libpixman-1.a")
set(UCHARDET_LIB "${LIB_DIR}/libuchardet.a")

# Ruby
set(RUBY_LIB "${LIB_DIR}/libruby.a")

# ====================
# Static Library Target
# ====================

# Build MKXP-Z as a native iOS application
add_executable(mkxpz MACOSX_BUNDLE ${MKXPZ_SOURCES})

target_compile_options(mkxpz PRIVATE
    -Wno-non-virtual-dtor
    -Wno-reorder
    -Wno-uninitialized
    -Wno-unknown-pragmas
    -Wno-deprecated-declarations
    -Wno-incompatible-pointer-types
    -Wno-pointer-sign
    -Wno-incompatible-pointer-types-discards-qualifiers
    -fdeclspec  # For Ruby 3.0+
)

# Link libraries
target_link_libraries(mkxpz
    ${SDL2_LIB}
    ${SDL2_IMAGE_LIB}
    ${SDL2_TTF_LIB}
    ${SDL2_SOUND_LIB}
    ${OPENAL_LIB}
    ${PHYSFS_LIB}
    ${PIXMAN_LIB}
    ${OGG_LIB}
    ${VORBIS_LIB}
    ${VORBISFILE_LIB}
    ${THEORA_LIB}
    ${THEORADEC_LIB}
    ${SIGC_LIB}
    ${UCHARDET_LIB}
    ${RUBY_LIB}
    # iOS System Frameworks
    "-framework Foundation"
    "-framework UIKit"
    "-framework OpenGLES"
    "-framework AudioToolbox"
    "-framework CoreAudio"
    "-framework CoreGraphics"
    "-framework CoreMotion"
    "-framework GameController"
    "-framework Metal"
    "-framework QuartzCore"
    "-framework AVFoundation"
    # System libraries
    bz2
    z
    iconv
)

# ====================
# Installation
# ====================

install(TARGETS mkxpz
    BUNDLE DESTINATION .
)

# Install headers for app integration
install(FILES
    ${MKXPZ_SRC_DIR}/config.h
    ${MKXPZ_SRC_DIR}/sharedstate.h
    ${MKXPZ_SRC_DIR}/binding.h
    DESTINATION include/mkxpz
)

message(STATUS "MKXP-Z iOS configuration complete")
message(STATUS "  Ruby library: ${RUBY_LIB}")
message(STATUS "  Build as static library for embedding in iOS app")

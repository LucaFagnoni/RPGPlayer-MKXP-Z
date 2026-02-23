 #include "fluid-fun.h"

#include <string.h>
#include <SDL_loadso.h>
#include <SDL_platform.h>

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

#include "debugwriter.h"

#if TARGET_OS_IPHONE
// iOS: Use static linking via SHARED_FLUID - no dynamic library loading
#ifndef SHARED_FLUID
#define SHARED_FLUID 1
#endif
#define FLUID_LIB "static"
#elif __LINUX__ || __ANDROID__
#define FLUID_LIB "libfluidsynth.so.3"
#elif MKXPZ_BUILD_XCODE
#define FLUID_LIB "@rpath/libfluidsynth.dylib"
#elif __APPLE__
#define FLUID_LIB "libfluidsynth.3.dylib"
#elif __WIN32__
#define FLUID_LIB "fluidsynth.dll"
#else
#error "platform not recognized"
#endif

struct FluidFunctions fluid;
#ifndef SHARED_FLUID
static void *so;
#endif

void initFluidFunctions()
{
#ifdef MKXPZ_NO_FLUIDSYNTH
	// Fluidsynth explicitly disabled for this platform
	Debug() << "Fluidsynth disabled for this platform. MIDI playback is disabled.";
	memset(&fluid, 0, sizeof(fluid));
	return;
#endif

#if TARGET_OS_IPHONE
	Debug() << "Initializing Fluidsynth for iOS (static linking)...";
#endif

#ifdef SHARED_FLUID

#define FLUID_FUN(name, type) \
	fluid.name = fluid_##name;

#define FLUID_FUN2(name, type, real_name) \
	fluid.name = real_name;

#else
	so = SDL_LoadObject(FLUID_LIB);

	if (!so)
		goto fail;

#define FLUID_FUN(name, type) \
	fluid.name = (type) SDL_LoadFunction(so, "fluid_" #name); \
	if (!fluid.name) \
		goto fail;

#define FLUID_FUN2(name, type, real_name) \
	fluid.name = (type) SDL_LoadFunction(so, #real_name); \
	if (!fluid.name) \
		goto fail;
#endif

#ifndef MKXPZ_NO_FLUIDSYNTH
FLUID_FUNCS
FLUID_FUNCS2
#endif

	return;

#ifndef SHARED_FLUID
fail:
	Debug() << "Failed to load " FLUID_LIB ". Midi playback is disabled.";

	memset(&fluid, 0, sizeof(fluid));
	SDL_UnloadObject(so);
	so = 0;
#endif
}

// TouchBar.h - iOS stub
// Touch Bar is macOS-only; this provides empty stubs for iOS build

#ifndef TOUCHBAR_H
#define TOUCHBAR_H

#include <SDL.h>

struct Config;

// Touch Bar is not available on iOS, provide empty stubs
static inline void initTouchBar(SDL_Window *win, const Config &conf) {
    (void)win;
    (void)conf;
}

static inline void updateTouchBarFPSDisplay(int fps) {
    (void)fps;
}

static inline void cleanupTouchBar() {}

#endif // TOUCHBAR_H

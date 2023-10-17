#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

// Takes the output of BrowserWindow.getNativeWindowHandle
// (which is a NSView* to the contentView of the window),
// finds the associated window and calls `makeKeyAndOrderFront`
// on it so that it's visible and focused without activating
// its application.
void MakeKeyAndOrderFront(const Napi::CallbackInfo &info) {
  NSView **contentViewPointer =
      reinterpret_cast<NSView **>(info[0].As<Napi::Buffer<NSView **>>().Data());
  NSView *contentView = *contentViewPointer;
  [[contentView window] makeKeyAndOrderFront:nil];
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "makeKeyAndOrderFront"),
              Napi::Function::New(env, MakeKeyAndOrderFront));

  return exports;
}

NODE_API_MODULE(active_app, Init)

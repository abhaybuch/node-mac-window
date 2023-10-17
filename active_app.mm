#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

void MakeKeyAndOrderFront(const Napi::CallbackInfo &info) {
  NSView** viewp = reinterpret_cast<NSView**>(info[0].As<Napi::Buffer<NSView**>>().Data());
  NSView* view = *viewp;
  [[view window] makeKeyAndOrderFront:nil];
}

Napi::Number
GetFrontmostApplicationProcessIdentifier(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  pid_t frontmostApplicationPid =
      [NSWorkspace sharedWorkspace].frontmostApplication.processIdentifier;
  return Napi::Number::New(env, frontmostApplicationPid);
}

Napi::String SetFrontmostApplicationProcessIdentifier(const Napi::CallbackInfo &info) {
  pid_t desiredFrontmostApplicationPid =
      info[0].As<Napi::Number>().Uint32Value();
  Napi::Env env = info.Env();
  NSRunningApplication *desiredFrontmostApplication = [NSRunningApplication
      runningApplicationWithProcessIdentifier:desiredFrontmostApplicationPid];
  if (desiredFrontmostApplication == nil) {
    return Napi::String::New(env, "nil");
  }
  // TODO(buch) use the non-deprecated option on mac os above 14
  BOOL success = [desiredFrontmostApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  if (success) {
    return Napi::String::New(env, "success");
  } else {
    return Napi::String::New(env, "fail");
  }
}

void Deactivate(const Napi::CallbackInfo &info) {
  [[NSApplication sharedApplication] hide:nil];
}

Napi::Number Activate(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
  [mainWindow orderFrontRegardless];
  [mainWindow makeKeyAndOrderFront:nil];
  return Napi::Number::New(env, mainWindow.windowNumber);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(
      Napi::String::New(env, "getFrontmostApplicationProcessIdentifier"),
      Napi::Function::New(env, GetFrontmostApplicationProcessIdentifier));
  exports.Set(
    Napi::String::New(env, "setFrontmostApplicationProcessIdentifier"),
    Napi::Function::New(env, SetFrontmostApplicationProcessIdentifier));
  exports.Set(
    Napi::String::New(env, "deactivate"),
    Napi::Function::New(env, Deactivate));
  exports.Set(
    Napi::String::New(env, "activate"),
    Napi::Function::New(env, Activate));
  exports.Set(
    Napi::String::New(env, "makeKeyAndOrderFront"),
    Napi::Function::New(env, MakeKeyAndOrderFront));

  return exports;
}

NODE_API_MODULE(active_app, Init)

// Bootstrap pref file for Firefox autoconfig. Tells Firefox to read mozilla.cfg
// from the app's Resources directory on startup. mozilla.cfg runs in privileged
// chrome context, so it can set new-tab routing that the WebExtension API
// (now sandboxed away from file://) cannot.
pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);

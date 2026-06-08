/****************************************************************************
 * user-overrides.js                                                        *
 * Applied on top of arkenfox user.js. Overrides and additions specific     *
 * to this profile.                                                         *
****************************************************************************/

/****************************************************************************
 * SECTION: AI / ML FEATURES                                                *
****************************************************************************/

// PREF: disable on-device ML inference engine (master switch)
user_pref("browser.ml.enable", false);

// PREF: disable AI chatbot sidebar
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.sidebar", false);

// PREF: disable key points / link preview AI
user_pref("browser.ml.linkPreview.enabled", false);

// PREF: disable smart tab group suggestions
user_pref("browser.tabs.groups.smart.enabled", false);

// PREF: disable on-device translations
user_pref("browser.translations.enable", false);
user_pref("browser.translations.select.enable", false);

// PREF: disable genai summarise and chat page features
user_pref("browser.ml.chat.page", false);
user_pref("browser.genai.chat.enabled", false);
user_pref("browser.genai.summarize.enabled", false);

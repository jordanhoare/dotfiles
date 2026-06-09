/****************************************************************************
 * user-overrides.js                                                        *
 * Applied on top of arkenfox user.js. Overrides and additions specific     *
 * to this profile. See ADR 0009 for the threat model and rationale.        *
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

/****************************************************************************
 * SECTION: STARTUP / HOME / NEW TAB                                        *
****************************************************************************/

// PREF: fresh launch each time, blank home, blank new tab
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "file://__HOME__/.config/firefox/newtab.html");

// PREF: strip activity-stream content from new tab even when shown
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

/****************************************************************************
 * SECTION: DNS - rely on OS resolver via ProtonVPN tunnel (ADR 0010)       *
****************************************************************************/

// PREF: disable DoH entirely; OS resolver hands DNS to the VPN tunnel
user_pref("network.trr.mode", 5);

/****************************************************************************
 * SECTION: PASSWORDS - Bitwarden owns credentials                          *
****************************************************************************/

user_pref("signon.rememberSignons", false);
user_pref("signon.autofillForms", false);
user_pref("signon.formlessCapture.enabled", false);
user_pref("signon.privateBrowsingCapture.enabled", false);

/****************************************************************************
 * SECTION: ADDRESS BAR / SEARCH SUGGESTIONS                                *
****************************************************************************/

// PREF: no live keystroke stream to the search engine
user_pref("browser.search.suggest.enabled", false);

// PREF: kill quicksuggest / trending / weather / topsites / recent searches
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.weather.featureGate", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.topsites", false);

/****************************************************************************
 * SECTION: TRACKING PROTECTION                                             *
****************************************************************************/

// PREF: pin ETP to strict; arkenfox sets cookieBehavior=5 but not the category
user_pref("browser.contentblocking.category", "strict");

// PREF: auto-reject cookie banners (normal and private windows)
user_pref("cookiebanners.service.mode", 1);
user_pref("cookiebanners.service.mode.privateBrowsing", 1);

/****************************************************************************
 * SECTION: SANITIZE ON SHUTDOWN                                            *
 * Keep cookies + history across restarts; wipe ephemeral state only.       *
****************************************************************************/

user_pref("privacy.sanitizeOnShutdown_v2.cookiesAndStorage", false);
user_pref("privacy.sanitizeOnShutdown_v2.historyFormDataAndDownloads", false);
user_pref("privacy.sanitizeOnShutdown_v2.cache", true);
user_pref("privacy.sanitizeOnShutdown_v2.formdata", true);
user_pref("privacy.sanitizeOnShutdown_v2.openWindows", true);
user_pref("privacy.sanitizeOnShutdown_v2.siteSettings", false);

// PREF: matching legacy keys (arkenfox sets these; mirror our intent)
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
user_pref("privacy.clearOnShutdown_v2.cache", true);
user_pref("privacy.clearOnShutdown_v2.siteSettings", false);

// PREF: don't expire cookies at session end; we manage shutdown above
user_pref("network.cookie.lifetimePolicy", 0);

/****************************************************************************
 * SECTION: POCKET / FORM AUTOFILL / DOWNLOADS UI                           *
****************************************************************************/

user_pref("extensions.pocket.enabled", false);

user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PREF: don't pop the downloads panel on every download
user_pref("browser.download.alwaysOpenPanel", false);

/****************************************************************************
 * SECTION: QUIET about:config                                              *
****************************************************************************/

user_pref("browser.aboutConfig.showWarning", false);

/****************************************************************************
 * SECTION: THEME                                                           *
 * Activate the Catppuccin Mocha Lavender static theme on profile init.     *
 * The theme XPI is force-installed via ExtensionSettings in security.nix.  *
****************************************************************************/

user_pref("extensions.activeThemeID", "{ad81280b-0506-473b-815b-9fbbdd754448}");

/****************************************************************************
 * SECTION: LAYOUT - vertical tabs on the left, minimal chrome              *
****************************************************************************/

user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.position_start", true);
user_pref("sidebar.main.tools", "history,bookmarks");
user_pref("browser.tabs.tabmanager.enabled", false);

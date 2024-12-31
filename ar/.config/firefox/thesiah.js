// These are changes made on top of the Arkenfox JS file to tweak it as
// desired. Any of these settings can be overridden by the user.

/* 0102: set startup page [SETUP-CHROME]
 * 0=blank, 1=home, 2=last visited page, 3=resume previous session
 * [NOTE] Session Restore is cleared with history (2811), and not used in Private Browsing mode
 * [SETTING] General>Startup>Restore previous session ***/
user_pref("browser.startup.page", 1);
/* 0103: set HOME+NEWWINDOW page
 * about:home=Firefox Home (default, see 0105), custom URL, about:blank
 * [SETTING] Home>New Windows and Tabs>Homepage and new windows ***/
user_pref("browser.startup.homepage", "https://www.searx.thesiah.xyz");
/* 1244: enable HTTPS-Only mode in all windows
 * When the top-level is HTTPS, insecure subresources are also upgraded (silent fail)
 * [SETTING] to add site exceptions: Padlock>HTTPS-Only mode>On (after "Continue to HTTP Site")
 * [SETTING] Privacy & Security>HTTPS-Only Mode (and manage exceptions)
 * [TEST] http://example.com [upgrade]
 * [TEST] http://httpforever.com/ | http://http.rip [no upgrade] ***/
user_pref("dom.security.https_only_mode", false); // [FF76+] Allow access to http (i.e. not https) sites:
/** SANITIZE ON SHUTDOWN: IGNORES "ALLOW" SITE EXCEPTIONS | v2 migration is FF128+ ***/
/* 2811: set/enforce what items to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] If "history" is true, downloads will also be cleared ***/
user_pref("privacy.clearOnShutdown.formdata", false); // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.history", false); // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.cookies", false); // Cookies
user_pref("privacy.clearOnShutdown.offlineApps", false); // Site Data
user_pref("privacy.clearOnShutdown.sessions", false); // Active Logins [DEFAULT: true]
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false); // Cookies, Site Data, Active Logins [FF128+]
/* 5010: disable location bar suggestion types
 * [SETTING] Search>Address Bar>When using the address bar, suggest ***/
user_pref("browser.urlbar.suggest.history", false); // Do not suggest web history in the URL bar:
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.topsites", false); // [FF78+]
/* 5012: disable location bar autofill
 * [1] https://support.mozilla.org/kb/address-bar-autocomplete-firefox#w_url-autocomplete ***/
user_pref("browser.urlbar.autoFill", false); // Do not autocomplete in the URL bar:
/* 5021: disable location bar using search
 * Don't leak URL typos to a search engine, give an error message instead
 * Examples: "secretplace,com", "secretplace/com", "secretplace com", "secret place.com"
 * [NOTE] This does not affect explicit user action such as using search buttons in the
 * dropdown, or using keyword search shortcuts you configure in options (e.g. "d" for DuckDuckGo) ***/
user_pref("keyword.enabled", true); // Enable the addition of search keywords:
/* 5510: control when to send a cross-origin referer
 * 0=always (default), 1=only if base domains match, 2=only if hosts match
 * [NOTE] Will cause breakage: older modems/routers and some sites e.g banks, vimeo, icloud, instagram ***/
user_pref("network.http.referer.XOriginPolicy", 2); // This could otherwise cause some issues on bank logins and other annoying sites:
/* 7018: disable service worker Web Notifications [FF44+]
 * [WHY] Web Notifications are behind a prompt (7002)
 * [1] https://blog.mozilla.org/en/products/firefox/block-notification-requests/
 * [-] https://bugzilla.mozilla.org/1842457 ***/
user_pref("dom.webnotifications.serviceworker.enabled", false);
/* 7019: disable Push Notifications [FF44+]
 * [WHY] Website "push" requires subscription, and the API is required for CRLite (1224)
 * [NOTE] To remove all subscriptions, reset "dom.push.userAgentID"
 * [1] https://support.mozilla.org/kb/push-notifications-firefox ***/
user_pref("dom.push.enabled", false);

// Bookmarks visibility
user_pref("browser.toolbars.bookmarks.visibility", "newtab");
user_pref("browser.uidensity", 1);
// Disable the pocket antifeature:
user_pref("extensions.pocket.enabled", false);
// Fullscreen notifications
user_pref("full-screen-api.warning.timeout", false);
// Disable Firefox sync and its menu entries
user_pref("identity.fxaccounts.enabled", false);
// screen & video & audio share
user_pref("media.webrtc.camera.allow-pipewire", false);
user_pref("media.webrtc.capture.allow-pipewire", true);
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);
// Keep cookies until expiration or user deletion:
user_pref("network.cookie.lifetimePolicy", 0);
// Prefil forms:
user_pref("signon.prefillForms", true);
// Enable custom userChrome.js:
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Fix the issue where right mouse button instantly clicks
user_pref("ui.context_menus.after_mouseup", true);
// Alt key menu
user_pref("ui.key.menuAccessKeyFocuses", false);
// Alt key change
user_pref("ui.key.menuAccessKey", -1);

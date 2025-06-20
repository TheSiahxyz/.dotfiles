// These are changes made on top of the Arkenfox JS file to tweak it as
// desired. Any of these settings can be overridden by the user.

// Startup
user_pref("browser.startup.page", 1); // 0=blank, 1=home, 2=last visited page, 3=resume previous session
user_pref("browser.startup.homepage", "https://www.searx.thesiah.xyz");
// HTTPS
user_pref("dom.security.https_only_mode", false); // [FF76+] Allow access to http (i.e. not https) sites:
user_pref("network.http.referer.XOriginPolicy", 0); // 0=always (default), 1=only if base domains match, 2=only if hosts match. This could otherwise cause some issues on bank logins and other annoying sites:
// URL
user_pref("keyword.enabled", true); // Enable the addition of search keywords:
// Notification
user_pref("dom.push.enabled", false);
// Form
user_pref("browser.formfill.enable", true);
// Bookmarks
user_pref("browser.toolbars.bookmarks.visibility", "newtab");
user_pref("browser.uidensity", 1);
// Disable the pocket antifeature:
user_pref("extensions.pocket.enabled", false);
// Fullscreen notifications
user_pref("full-screen-api.warning.timeout", false);
// Disable Firefox sync and its menu entries
user_pref("identity.fxaccounts.enabled", false);
// Keep cookies until expiration or user deletion:
user_pref("network.cookie.lifetimePolicy", 0);
// Enable custom userChrome.js:
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Fix the issue where right mouse button instantly clicks
user_pref("ui.context_menus.after_mouseup", true);
// Alt key menu
user_pref("ui.key.menuAccessKeyFocuses", false);
// Alt key change
user_pref("ui.key.menuAccessKey", -1);

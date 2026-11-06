// Extra overrides for the work profile ($USER.work), appended after thesiah.js.
// Relaxes arkenfox/LibreWolf restrictions that get in the way of daily use.
// Protections that don't cost convenience (tracker blocking, uBlock, ...) stay.

// Marker read by ~/.librewolf/librewolf.overrides.cfg for prefs LibreWolf
// forces with pref() (user.js can't override those)
user_pref("thesiah.profile", "work");

// Keep logins, cache and history across restarts (no cleanup on shutdown)
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.clearOnShutdown_v2.cache", false);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.sessionstore.privacy_level", 0); // restore form data/cookies with the session

// Standard tracking protection: strict breaks SSO logins, embeds and payment popups
user_pref("browser.contentblocking.category", "standard");

// No fingerprinting spoofing: real timezone (calendar/meeting times), no canvas noise
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.fingerprintingProtection", false);

// Search suggestions in the address bar
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.urlbar.suggest.searches", true);

// Save downloads straight to the download folder without asking
user_pref("browser.download.useDownloadDir", true);
user_pref("browser.download.always_ask_before_handling_new_types", false);

// Firefox defaults: allow muted autoplay, soft-fail OCSP, send full cross-origin referrer
user_pref("media.autoplay.default", 1); // 0=allow all, 1=block audible, 5=block all
user_pref("security.OCSP.require", false);
user_pref("network.http.referer.XOriginTrimmingPolicy", 0);

// Video calls (Meet, Zoom, ...): let WebRTC use all network paths
user_pref("media.peerconnection.ice.default_address_only", false);

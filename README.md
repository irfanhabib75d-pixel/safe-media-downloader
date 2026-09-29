# Safe Media Downloader (Flutter / Dart)

A production-grade, **permission-first** mobile media downloader for **Android** and **iOS**. The application allows users to inspect and download high-resolution photos, videos, and audio from platforms whose official developer APIs and Terms of Service explicitly permit direct third-party downloading.

---

## 🌟 Key Architectural Features

- **Permission-First Architecture:** Inspects media only via documented, official platform REST/Action APIs.
- **Zero Scraping & Reverse Engineering:** Never parses private HTML, skips DRM, or circumvents access controls.
- **Robust Streaming Download Engine:**
  - Resumable downloads via HTTP `Range: bytes=X-` headers with `.part` file preservation.
  - Live progress tracking: Percentage, transferred/total bytes, transfer speed (KB/s, MB/s), and real-time ETA.
  - Controls: Start, pause, resume, cancel, retry, and clean removal.
  - Concurrency management (max 2 parallel downloads to preserve network bandwidth and battery life).
- **Security & Integrity Protections:**
  - Strict HTTPS enforcement.
  - Server-Side Request Forgery (SSRF) and private IP / loopback address blocking (`127.0.0.1`, `10.0.0.0/8`, `192.168.0.0/16`, `169.254.0.0/16`, `::1`).
  - Strict destination host allowlists and redirect safety validation.
  - Filename sanitization preventing path traversal (`../`) and execution vulnerabilities.
  - Encrypted secure token storage backed by Android Keystore and iOS Keychain.
- **Rights & Content Safeguards:**
  - Mandatory user rights confirmation before initiating any download.
  - Creator attribution and Creative Commons / Public Domain license preservation.
  - No watermark removal, audio stripping, re-encoding, or reposting features.
  - Minimal local download history stored strictly on-device without remote telemetry or third-party ads.
- **Dual Localization & Modern Design:**
  - Full support for **English** and **Roman Urdu** (`ur_Latn`).
  - High-contrast, accessibility-tested light and dark themes.

---

## 📱 Supported vs. Unsupported Sources

| Source | Support Status | Authorized Method |
| :--- | :--- | :--- |
| **Wikimedia Commons** | Supported | Official MediaWiki Action API & REST Core API |
| **Internet Archive** | Supported | Official Archive Metadata API |
| **Flickr** | Supported | Official REST API (`can_download == 1` & CC photos) |
| **Pexels** | Supported | Official Pexels REST API |
| **Reddit** | Supported | Official JSON API (`i.redd.it` direct author media) |
| **YouTube** | **Unsupported** | Blocked under YouTube Terms §5.B |
| **TikTok** | **Unsupported** | Blocked under TikTok Terms §5 |
| **Instagram** | **Unsupported** | Blocked under Meta Platform Terms §3.2.1 |
| **Facebook** | **Unsupported** | Blocked under Facebook Terms §3.2.3 |
| **X (Twitter)** | **Unsupported** | Blocked under X Developer Agreement |
| **Pinterest** | **Unsupported** | Blocked under Pinterest Terms of Service |

*For a full legal review of each platform, see [SOURCE_SUPPORT.md](file:///d:/Anti%20gravity/downloader/New%20folder/SOURCE_SUPPORT.md).*

---

## 🛠️ Prerequisites & Developer Accounts

1. **Flutter SDK:** Version `3.10.0` or higher (`Dart >= 3.0.0`).
2. **Android Studio / Xcode:** For Android Gradle builds and iOS CocoaPods management.
3. **Optional API Keys (configured in Settings > Provider Authorization):**
   - **Pexels API Key:** Register at [pexels.com/api](https://www.pexels.com/api/) (free tier available).
   - **Flickr API Key:** Register at [flickr.com/services/api](https://www.flickr.com/services/api/).
   - *Wikimedia Commons, Internet Archive, and Reddit author endpoints operate with public open access.*

---

## 🚀 Installation & Build Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Locally on an Emulator or Device
```bash
# Run on connected Android or iOS device
flutter run
```

### 3. Build Production Artifacts

#### Android (APK / App Bundle)
```bash
# Build release APK
flutter build apk --release

# Build Google Play App Bundle (AAB)
flutter build appbundle --release
```

#### iOS (IPA)
```bash
flutter build ipa --release
```

---

## 🔒 Security & Privacy Model

- **No Backend:** The app is a standalone client. No user data, URLs, or downloaded media are transmitted to external servers.
- **Secure Token Storage:** Tokens are encrypted in `flutter_secure_storage` using Android Keystore and iOS Keychain.
- **Zero Logging of Secrets:** API keys and authorization headers are never printed to debug logs.
- **Maximum File Limit:** 500 MB safe threshold to protect device storage.

---

## 📄 Legal & Compliance Documents

- [SOURCE_SUPPORT.md](file:///d:/Anti%20gravity/downloader/New%20folder/SOURCE_SUPPORT.md) - Platform Terms of Service Analysis
- [LICENSE](file:///d:/Anti%20gravity/downloader/New%20folder/LICENSE) - Commercial License Template
- [TERMS_OF_USE_TEMPLATE.md](file:///d:/Anti%20gravity/downloader/New%20folder/TERMS_OF_USE_TEMPLATE.md) - Terms of Use Template
- [PRIVACY_POLICY_TEMPLATE.md](file:///d:/Anti%20gravity/downloader/New%20folder/PRIVACY_POLICY_TEMPLATE.md) - Privacy Policy Template
- [THIRD_PARTY_LICENSES.md](file:///d:/Anti%20gravity/downloader/New%20folder/THIRD_PARTY_LICENSES.md) - Dependency Inventory & Licensing
- [STORE_LISTING_DRAFT.md](file:///d:/Anti%20gravity/downloader/New%20folder/STORE_LISTING_DRAFT.md) - App Store & Google Play Listing Draft

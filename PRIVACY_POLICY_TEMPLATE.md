# Privacy Policy (Template)

**Last Updated:** [INSERT_DATE]  
**App Name:** [APP_NAME_PLACEHOLDER] (Safe Media Downloader)  
**Company:** [COMPANY_LEGAL_NAME_PLACEHOLDER]  
**Contact Email:** [PRIVACY_EMAIL_PLACEHOLDER]  

> **NOTICE:** This document is a privacy policy template designed for standalone, on-device mobile applications. Review and update this document to match your company's actual operating details before publishing.

---

## 1. Overview & Privacy Principles

[COMPANY_LEGAL_NAME_PLACEHOLDER] ("we", "our", or "us") is committed to protecting your privacy. [APP_NAME_PLACEHOLDER] operates on a **local, on-device architecture**. We do not operate remote user tracking servers, do not collect personal analytics, and do not sell user data.

## 2. Information Handled by the App

### A. URLs Submitted by You
- When you paste or enter a URL, it is processed locally on your device to query official public APIs.
- URLs submitted are never uploaded to our servers.

### B. Download History & Media Files
- Completed download metadata (title, provider name, date, file path, license information) is stored **exclusively in your device's local application storage** (SharedPreferences/device sandbox).
- Downloaded media files are stored locally in your device's Downloads folder or MediaStore/Photo Library with your explicit permission.
- We have no access to your downloaded files.

### C. Developer API Keys & Authentication Tokens
- Any custom API keys or OAuth tokens entered in the app are stored encrypted in **Android Keystore** or **iOS Keychain** via secure hardware-backed storage.
- Tokens are used solely to authenticate direct requests between your device and the official platform API.

### D. Analytics & Advertising
- **No Third-Party Analytics:** The App contains no tracking SDKs, telemetry frameworks, or behavioral trackers in Version 1.0.
- **No Advertising Networks:** The App does not display third-party advertisements or share device identifiers with ad networks.

## 3. Network Communications

The App initiates network connections **only** to:
1. Documented official API endpoints (e.g., `commons.wikimedia.org`, `api.pexels.com`, `api.flickr.com`, `archive.org`, `reddit.com`).
2. Officially verified download CDNs belonging to those platforms.

The App does not connect to unknown servers, local IP addresses, or tracking intermediaries.

## 4. Device Permissions Requested

| Permission | Purpose |
| :--- | :--- |
| **Internet Access (`INTERNET`)** | Required to fetch media metadata and authorized files from official APIs. |
| **Storage / MediaStore (`READ_MEDIA_*` / `WRITE_EXTERNAL_STORAGE`)** | Required to save downloaded images, videos, and audio to your device storage. |
| **Photo Library (`NSPhotoLibraryAddUsageDescription`)** | Required on iOS to save images and videos to the Photos app upon user confirmation. |
| **Notifications (`POST_NOTIFICATIONS`)** | Used exclusively to display download progress and completion alerts for user-initiated downloads. |

## 5. Children's Privacy

The App does not knowingly collect or solicit personal information from children under the age of 13 (or under the age of 16 in the EEA).

## 6. Updates to This Privacy Policy

We may update this Privacy Policy from time to time. Any changes will be posted in the App and accompanied by an updated "Last Updated" date.

## 7. Contact Us

If you have any questions or privacy inquiries regarding this policy, please contact us at:  
**Privacy Officer:** [PRIVACY_OFFICER_NAME_PLACEHOLDER]  
**Email:** [PRIVACY_EMAIL_PLACEHOLDER]  
**Mailing Address:** [COMPANY_PHYSICAL_ADDRESS_PLACEHOLDER]  

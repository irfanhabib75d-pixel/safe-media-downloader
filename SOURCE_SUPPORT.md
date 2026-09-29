# Source Support Matrix & Policy Documentation Review

**Review Date:** September 29, 2026  
**Compliance Standard:** Permission-First, Zero-Scraping, Official API Authorization Only  
**Enforcement Engine:** Strict HTTPS URL Host Allowlisting, Endpoint Authorization, and Rights Confirmation

---

## 1. Executive Policy & Compliance Summary

Safe Media Downloader enforces a **strict permission-first architecture**. A platform is integrated into the app if and only if that platform's official developer terms and public APIs explicitly authorize third-party media retrieval.

### Prohibited Actions (Zero Tolerance)
- **No Web Scraping:** The app never parses HTML, scrapes DOM elements, or inspects undocumented page scripts.
- **No Hidden Manifest Extraction:** The app never reverse-engineers HLS/DASH streaming manifests (m3u8, mpd) from unauthorized players.
- **No Private API Access:** The app never simulates private mobile apps or reverse-engineers internal backend endpoints.
- **No Authentication Bypassing:** The app never bypasses paywalls, DRM, access tokens, watermarks, or download restrictions.
- **No Credential Harvesting:** The app never requests or accepts a user's social-media account passwords.
- **No Rights Overrides:** A user's declaration of media ownership does not override the platform's Terms of Service.

---

## 2. Platform-by-Platform Legal & Technical Assessment

| Platform | Official Support Status | Official Policy & Terms Reference | Permitted Method | Required Scopes / Auth | Review Date |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Wikimedia Commons** | **Supported** | [Commons:API](https://commons.wikimedia.org/wiki/Commons:API) | Official MediaWiki Action API (`action=query&prop=imageinfo`) & REST Core API | None (Open Public CC/Public Domain API) | 2026-09-29 |
| **Internet Archive** | **Supported** | [Archive Metadata API](https://archive.org/help/aboutapi.htm) | Official Metadata API (`/metadata/{identifier}`) for public domain items | None (Open Public Access) | 2026-09-29 |
| **Flickr** | **Supported** | [Flickr Services API Terms](https://www.flickr.com/services/api/) | Official REST API (`flickr.photos.getSizes`, `flickr.photos.getInfo`) | `read` (Honors `can_download == 1` & CC flags) | 2026-09-29 |
| **Pexels** | **Supported** | [Pexels API Documentation](https://www.pexels.com/api/documentation/) | Official Pexels REST API (`/v1/photos/{id}`, `/videos/videos/{id}`) | Free Pexels Developer API Key | 2026-09-29 |
| **Reddit** | **Supported (Author Media)** | [Reddit Data API Terms](https://www.reddit.com/dev/api/) | Official Public JSON Endpoint (`/comments/{id}.json`) for `i.redd.it` direct author assets | Public User-Agent compliance / OAuth `read` | 2026-09-29 |
| **YouTube** | **Unsupported** | [YouTube Terms of Service §5.B](https://www.youtube.com/static?template=terms) | **None.** Third-party stream downloading is explicitly prohibited. | N/A | 2026-09-29 |
| **TikTok** | **Unsupported** | [TikTok Terms of Service §5](https://www.tiktok.com/legal/page/row/terms-of-service/en) | **None.** Extraction of media or bypassing application controls is forbidden. | N/A | 2026-09-29 |
| **Instagram** | **Unsupported (Consumer Links)** | [Meta Platform Terms §3.2.1](https://help.instagram.com/581066165581870) | **None for consumer link parsing.** Meta Graph API only permits authenticated business accounts to fetch their own owned media. | N/A for public link downloading | 2026-09-29 |
| **Facebook** | **Unsupported** | [Facebook Terms of Service §3.2.3](https://www.facebook.com/terms.php) | **None.** Automated media extraction and downloading without express consent is prohibited. | N/A | 2026-09-29 |
| **X (Twitter)** | **Unsupported** | [X Developer Agreement §A.1](https://twitter.com/en/tos) | **None for media downloading.** API v2 permits timeline presentation only; offline caching of media streams is forbidden. | N/A | 2026-09-29 |
| **Pinterest** | **Unsupported** | [Pinterest Terms of Service](https://policy.pinterest.com/en/terms-of-service) | **None.** Scraping or capturing media off pinboards is prohibited. | N/A | 2026-09-29 |

---

## 3. Detailed Provider Implementation Notes

### Supported Providers

#### 1. Wikimedia Commons
- **Endpoint:** `https://commons.wikimedia.org/w/api.php`
- **Permitted Hosts:** `upload.wikimedia.org`, `commons.wikimedia.org`
- **Behavior:** Queries the official MediaWiki Action API with `action=query&prop=imageinfo&iiprop=url|size|mime|extmetadata|thumburl`.
- **Licensing Handling:** Extracts `LicenseShortName`, `LicenseUrl`, and author attribution. Users are provided full resolution and scaled HD download options.

#### 2. Internet Archive (Archive.org)
- **Endpoint:** `https://archive.org/metadata/{identifier}`
- **Permitted Hosts:** `archive.org`, `*.archive.org`, `ia800000.us.archive.org`, `ia600000.us.archive.org`
- **Behavior:** Retrieves structured metadata for public domain and Creative Commons archival works.
- **Safety Checks:** Filters exclusively for safe multimedia formats (MP4, MP3, FLAC, WebM, JPEG, PNG, PDF) and excludes executable or server script files.

#### 3. Flickr
- **Endpoint:** `https://api.flickr.com/services/rest/`
- **Permitted Hosts:** `*.staticflickr.com`, `live.staticflickr.com`
- **Behavior:** Queries `flickr.photos.getInfo` to check if `usage.candownload == 1`. If the owner has disabled downloads, the app marks the photo as restricted and refuses download.

#### 4. Pexels
- **Endpoint:** `https://api.pexels.com/v1/photos/{id}` and `/videos/videos/{id}`
- **Permitted Hosts:** `images.pexels.com`, `videos.pexels.com`, `*.pexels.com`
- **Behavior:** Calls official Pexels REST endpoints using authorized developer keys. Generates official resolution options (Original, Large 2x, Large, HD video).

#### 5. Reddit (Direct Author Media)
- **Endpoint:** `https://www.reddit.com/comments/{id}.json`
- **Permitted Hosts:** `i.redd.it`, `v.redd.it`, `preview.redd.it`
- **Behavior:** Strictly inspects posts with author-hosted `i.redd.it` or `v.redd.it` assets. External link aggregates or third-party scraper embeds are rejected.

---

### Unsupported Providers (Why They Are Blocked)

#### YouTube
- **Terms Checked:** YouTube Terms of Service Section 5.B ("Permissions and Restrictions").
- **Exact Prohibitive Clause:** *"You are not allowed to... access, reproduce, download, distribute, transmit, broadcast, display, sell, license, alter, modify or otherwise use any part of the Service or any Content except: (a) as expressly authorized by the Service; or (b) with prior written permission from YouTube and, if applicable, the respective rights holders."*
- **App Action:** Blocks all `youtube.com` and `youtu.be` links. Shows an educational dialog directing users to the official YouTube app and YouTube Premium offline viewing.

#### TikTok
- **Terms Checked:** TikTok Terms of Service Section 5 ("Access to and Use of Our Services").
- **Exact Prohibitive Clause:** *"You may not... copy, modify, adapt, translate, reverse engineer, disassemble, decompile or create any derivative works based on the Services, including any files, tables or documentation... or extract any data or content from the Platform using automated systems."*
- **App Action:** Rejects all `tiktok.com` links. Provides a direct link to open the TikTok official app.

#### Meta (Instagram & Facebook)
- **Terms Checked:** Meta Platform Terms Section 3.2.1 and Instagram Terms of Use Section 3.2.
- **Exact Prohibitive Clause:** *"You cannot do anything that facilitates or encourages scraping, harvesting, or automated collection of content without our prior written permission."*
- **App Action:** Rejects Instagram and Facebook post links. The app offers only "Open in official app / browser".

#### X (Twitter) & Pinterest
- **Terms Checked:** X Developer Agreement Section A.1 and Pinterest Terms of Service.
- **Exact Prohibitive Clause:** Prohibits downloading and distributing media assets outside official client timelines and pinboards.
- **App Action:** Blocked with plain-language explanation and direct link to official platform apps.

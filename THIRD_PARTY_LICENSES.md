# Third-Party Licenses & Dependency Inventory

This document lists all open-source packages and dependencies used in Safe Media Downloader, along with their respective version numbers and license types.

All third-party libraries incorporated in this application are distributed under permissive open-source licenses (MIT, BSD-3-Clause, Apache 2.0) that permit commercial mobile application distribution.

---

## 1. Core Framework Dependencies

| Package / SDK | Version | License | Upstream Repository / Source |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `>= 3.10.0` | BSD-3-Clause | https://github.com/flutter/flutter |
| **Dart SDK** | `>= 3.0.0 < 4.0.0` | BSD-3-Clause | https://github.com/dart-lang/sdk |
| **flutter_localizations** | SDK | BSD-3-Clause | https://github.com/flutter/flutter |

---

## 2. Runtime Package Dependencies

| Package Name | Version | License | Primary Purpose |
| :--- | :--- | :--- | :--- |
| **http** | `^1.2.1` | BSD-3-Clause | Official HTTP client for API inspection and streaming Range requests |
| **flutter_secure_storage**| `^9.0.0` | BSD-3-Clause | Encrypted token storage (Android Keystore & iOS Keychain) |
| **crypto** | `^3.0.3` | BSD-3-Clause | Cryptographic hashing and URL validation utilities |
| **path_provider** | `^2.1.2` | BSD-3-Clause | Platform directory paths for saving media files |
| **path** | `^1.9.0` | BSD-3-Clause | Path manipulation and filename sanitization |
| **shared_preferences** | `^2.2.3` | BSD-3-Clause | Minimal on-device key-value store for download history & settings |
| **share_plus** | `^9.0.0` | BSD-3-Clause | Platform native share sheet integration |
| **open_filex** | `^4.4.0` | MIT | Platform default media viewer launcher |
| **url_launcher** | `^6.2.6` | BSD-3-Clause | Safe opening of official browser URLs for unsupported sources |
| **flutter_local_notifications** | `^17.1.1` | BSD-3-Clause | Foreground notifications for live download progress |
| **intl** | `^0.19.0` | BSD-3-Clause | Internationalization, number, and date formatting |
| **uuid** | `^4.3.3` | MIT | RFC4122 compliant UUID generation for queue tasks |
| **provider** | `^6.1.2` | MIT | Reactive state management for download queue, theme, and locale |

---

## 3. Development & Linting Dependencies

| Package Name | Version | License | Purpose |
| :--- | :--- | :--- | :--- |
| **flutter_test** | SDK | BSD-3-Clause | Unit and widget test framework |
| **flutter_lints** | `^3.0.0` | BSD-3-Clause | Official Flutter recommended style and linting rules |

---

## 4. License Texts

### BSD-3-Clause License
```text
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
```

### MIT License
```text
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

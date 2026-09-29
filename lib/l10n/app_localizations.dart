import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English'),
  romanUrdu('ur_Latn', 'Roman Urdu');

  final String code;
  final String displayName;
  const AppLanguage(this.code, this.displayName);
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // General & Nav
      'app_title': 'Safe Media Downloader',
      'nav_home': 'Home',
      'nav_queue': 'Queue',
      'nav_downloads': 'Saved',
      'nav_settings': 'Settings',

      // Home Screen
      'home_header_title': 'Permission-First Media Downloader',
      'home_header_subtitle':
          'Download photos, videos & audio from officially permitted sources with verified creator permissions.',
      'url_input_placeholder': 'Paste official media link here (HTTPS only)...',
      'paste_button': 'Paste Link',
      'inspect_button': 'Inspect Link',
      'inspecting_url': 'Checking source permissions & official API...',
      'supported_sources_title': 'Officially Supported Sources',
      'supported_sources_desc':
          'We only connect to official APIs that explicitly authorize direct media downloads.',
      'recent_downloads_title': 'Recent Downloads',
      'view_all': 'View All',
      'no_recent_downloads': 'No recent downloads yet.',

      // Validation & Errors
      'err_empty_url': 'Please enter or paste a URL.',
      'err_invalid_url': 'Invalid URL format. Must start with https://',
      'err_unsupported_source': 'Unsupported Source Platform',
      'err_unsupported_desc':
          'This platform does not provide an authorized third-party download API, or its Terms of Service prohibit third-party downloading.',
      'open_in_browser': 'Open in Official App / Browser',
      'err_network_failed': 'Network connection failed. Please check internet.',
      'err_rate_limit': 'Official API rate limit reached. Please try later.',
      'err_media_unavailable': 'Media is private, removed, or not downloadable.',
      'err_file_too_large': 'File exceeds maximum safe download limit (500 MB).',
      'err_storage_permission': 'Storage permission is required to save media.',

      // Media Options & Inspection Sheet
      'media_ready_title': 'Download Details',
      'media_title': 'Title',
      'media_source': 'Source',
      'media_author': 'Creator / Author',
      'media_license': 'License / Rights',
      'media_size_est': 'Estimated Size',
      'media_resolution': 'Quality / Resolution',
      'select_option': 'Select Download Option',
      'start_download_btn': 'Start Authorized Download',
      'cancel_btn': 'Cancel',

      // Rights Confirmation Dialog
      'rights_dialog_title': 'Rights & Compliance Confirmation',
      'rights_dialog_body':
          'Before downloading, please confirm that you own this media, hold a valid license (e.g. Creative Commons / Public Domain), or have explicit permission from the copyright holder to save a copy for personal use.\n\nNote: This confirmation does not grant legal rights or override the source platform’s Terms of Service.',
      'rights_checkbox':
          'I confirm I have permission/license to save this media and will respect author attribution.',
      'confirm_and_download': 'Confirm & Download',

      // Queue Screen
      'queue_title': 'Download Queue',
      'queue_empty_title': 'No Active Downloads',
      'queue_empty_desc': 'Links you inspect and start will appear here with live speed and progress.',
      'status_queued': 'Queued',
      'status_downloading': 'Downloading',
      'status_paused': 'Paused',
      'status_completed': 'Completed',
      'status_failed': 'Failed',
      'status_cancelled': 'Cancelled',
      'btn_pause': 'Pause',
      'btn_resume': 'Resume',
      'btn_retry': 'Retry',
      'btn_cancel': 'Cancel',
      'btn_remove': 'Remove',
      'speed_label': 'Speed',
      'eta_label': 'ETA',
      'pause_all': 'Pause All',
      'resume_all': 'Resume All',
      'clear_completed': 'Clear Completed',

      // Downloads Screen
      'downloads_title': 'Saved Media',
      'downloads_empty_title': 'No Saved Files Yet',
      'downloads_empty_desc': 'Your completed downloads will be safely stored and listed here.',
      'btn_open': 'Open File',
      'btn_share': 'Share',
      'btn_show_in_files': 'Show in Files',
      'btn_delete': 'Delete',
      'delete_confirm_title': 'Delete Downloaded File?',
      'delete_confirm_body': 'This will delete the file from your device storage.',

      // Settings Screen
      'settings_title': 'Settings & Policy',
      'section_general': 'General',
      'language_label': 'Language / Zaban',
      'theme_label': 'App Theme',
      'theme_system': 'System Default',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'section_storage': 'Storage & Security',
      'save_location_label': 'Save Destination',
      'save_location_desc': 'Downloads / MediaStore (Public Gallery)',
      'secure_keystore_status': 'Secure Storage (Keystore / Keychain)',
      'secure_keystore_active': 'Active & Encrypted',
      'section_compliance': 'Compliance & Transparency',
      'supported_sources_matrix': 'Source Support Matrix & API Docs',
      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'third_party_licenses': 'Third-Party Licenses',
      'about_app': 'About Safe Media Downloader',
      'app_version': 'Version 1.0.0 (Permission-First Build)',
      'disclaimer_notice':
          'Safe Media Downloader strictly respects copyright, DRM, and platform Terms of Service. No scraping or unauthorized downloading is performed.',
    },
    'ur_Latn': {
      // General & Nav
      'app_title': 'Safe Media Downloader',
      'nav_home': 'Home',
      'nav_queue': 'Queue',
      'nav_downloads': 'Saved',
      'nav_settings': 'Settings',

      // Home Screen
      'home_header_title': 'Ijazat-Yafta Media Downloader',
      'home_header_subtitle':
          'Official APIs ke zariye tasaveer, videos aur audio download karein jahan source ijazat deta hai.',
      'url_input_placeholder': 'Official media link yahan paste karein (Sirf HTTPS)...',
      'paste_button': 'Link Paste Karein',
      'inspect_button': 'Link Check Karein',
      'inspecting_url': 'Platform permissions aur official API check ho rahi hai...',
      'supported_sources_title': 'Qanooni Tor Par Manzoor Sources',
      'supported_sources_desc':
          'Hum sirf un official APIs se connect karte hain jo direct download ki ijazat dete hain.',
      'recent_downloads_title': 'Haalia Downloads',
      'view_all': 'Sab Dekhein',
      'no_recent_downloads': 'Abhi koi download nahi hua.',

      // Validation & Errors
      'err_empty_url': 'Barah-e-karam link darj ya paste karein.',
      'err_invalid_url': 'Link ghalat hai. Link https:// se shuru hona chahiye.',
      'err_unsupported_source': 'Ghair-Manzoor Platform',
      'err_unsupported_desc':
          'Yeh platform third-party download API faraham nahi karta ya is ke Terms of Service downloading se mana karte hain.',
      'open_in_browser': 'Official App / Browser mein Kholein',
      'err_network_failed': 'Internet connection ka masla hai. Check karein.',
      'err_rate_limit': 'API ki limit poori ho gayi hai. Baad mein koshish karein.',
      'err_media_unavailable': 'Media private hai ya download ke liye dastiyab nahi.',
      'err_file_too_large': 'File safe download limit (500 MB) se bari hai.',
      'err_storage_permission': 'Media save karne ke liye storage permission zaroori hai.',

      // Media Options & Inspection Sheet
      'media_ready_title': 'Download Maloomat',
      'media_title': 'Unwan (Title)',
      'media_source': 'Platform / Source',
      'media_author': 'Banane Wala (Creator)',
      'media_license': 'License / Ijazat',
      'media_size_est': 'Andaza Size',
      'media_resolution': 'Quality / Resolution',
      'select_option': 'Download Option Chunein',
      'start_download_btn': 'Manzoor Download Shuru Karein',
      'cancel_btn': 'Kansil',

      // Rights Confirmation Dialog
      'rights_dialog_title': 'Copyright Aur Ijazat Ki Tasdeeq',
      'rights_dialog_body':
          'Download karne se pehle tasdeeq karein ke aap ke paas is media ka license (jaise Creative Commons/Public Domain) ya author ki ijazat mojood hai.\n\nNote: Yeh tasdeeq platform ke Terms of Service ko override nahi karti.',
      'rights_checkbox':
          'Main tasdeeq karta/karti hoon ke mere paas is media ko save karne ki ijazat hai.',
      'confirm_and_download': 'Tasdeeq Aur Download',

      // Queue Screen
      'queue_title': 'Download Queue',
      'queue_empty_title': 'Koi Active Download Nahi',
      'queue_empty_desc': 'Aap ke shuru kiye gaye downloads speed aur progress ke sath yahan nazar aayenge.',
      'status_queued': 'Queue Mein',
      'status_downloading': 'Download Ho Raha Hai',
      'status_paused': 'Ruka Hua',
      'status_completed': 'Mukammal',
      'status_failed': 'Nakaam',
      'status_cancelled': 'Mansookh',
      'btn_pause': 'Rokein',
      'btn_resume': 'Dobara Shuru',
      'btn_retry': 'Dobara Koshish',
      'btn_cancel': 'Mansookh',
      'btn_remove': 'Khatam Karein',
      'speed_label': 'Raftaar',
      'eta_label': 'Baqi Waqt',
      'pause_all': 'Sab Rokein',
      'resume_all': 'Sab Chalaein',
      'clear_completed': 'Mukammal Saaf Karein',

      // Downloads Screen
      'downloads_title': 'Saved Media',
      'downloads_empty_title': 'Abhi Koi File Saved Nahi',
      'downloads_empty_desc': 'Aap ki mukammal downloads yahan mehfooz aur listed hongi.',
      'btn_open': 'File Kholein',
      'btn_share': 'Share Karein',
      'btn_show_in_files': 'Files Mein Dekhein',
      'btn_delete': 'Delete Karein',
      'delete_confirm_title': 'Kya File Delete Karni Hai?',
      'delete_confirm_body': 'Yeh file aap ke device storage se delete ho jayegi.',

      // Settings Screen
      'settings_title': 'Settings Aur Policy',
      'section_general': 'Aam Settings',
      'language_label': 'Zaban (Language)',
      'theme_label': 'App Theme',
      'theme_system': 'System Default',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'section_storage': 'Storage Aur Security',
      'save_location_label': 'Save Hone Ki Jagah',
      'save_location_desc': 'Downloads / MediaStore (Public Gallery)',
      'secure_keystore_status': 'Secure Storage (Keystore / Keychain)',
      'secure_keystore_active': 'Fa’al Aur Encrypted',
      'section_compliance': 'Qanooni Sharafat Aur Shafafiyat',
      'supported_sources_matrix': 'Supported Sources Ki List Aur API Docs',
      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'third_party_licenses': 'Third-Party Licenses',
      'about_app': 'App Ke Baare Mein',
      'app_version': 'Version 1.0.0 (Permission-First)',
      'disclaimer_notice':
          'Yeh app copyright aur platforms ke Terms of Service ka ehtiram karti hai. Koi scraping ya ghair-qanooni download nahi kiya jata.',
    },
  };

  String translate(String key) {
    final langKey = locale.languageCode == 'ur' ? 'ur_Latn' : 'en';
    return _localizedValues[langKey]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get(String key) => translate(key);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

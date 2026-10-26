import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_us.dart';
import 'fr_FR.dart';
import 'ko_kr.dart';

class LocalizationService extends Translations {
  //Default Locale
  static final locale = Locale('en', 'US');

  //fallback saves the day when the locale gets in trouble
  static final fallbackLocale = Locale('tr', 'TR');

  //Supported Languages and Needs to be same order as in locales
  //static final languages = ['English', '한국어', 'FRANÇAIS'];
  static final languages = ['English', '한국어'];

  //Supported Locales and Needs to be in same order as in languages

  static final locales = [
    Locale('en', 'US'),
    Locale('ko', 'KR'),
    Locale('fr', 'FR')
  ];

//Keys and their translation
// Translations are separatd maps in 'langs' file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_us': enUS, // lang/en_us.dart
        'ko_kr': koKR, // lang/ko_kr.dart
        'fr_FR': frFR // lang/fr-FR.dart
      };

  void changeLocale(String lang) {
    final locale = getLocaleFromLanguages(lang);
    Get.updateLocale(locale!);
  }

  Locale? getLocaleFromLanguages(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if (lang == languages[i]) return locales[i];
    }
    return Get.locale;
  }
}

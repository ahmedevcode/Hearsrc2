import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModel with ChangeNotifier {
  late Map<String, dynamic> appConfig; // Marked as late
  bool isLoading = true;
  late String message;

  // bool darkTheme = kDefaultDarkTheme ?? false;
  String _langCode = 'EN';

  bool showDemo = false;
  late String username;
  bool isInit = false;
  late Map<String, dynamic> drawer;

  // ListingType listingType;

  String get langCode => _langCode;
  late ThemeMode themeMode;

  AppModel() {
    getConfig();
  }

  bool get darkTheme => themeMode == ThemeMode.dark;

  set darkTheme(bool value) =>
      themeMode = value ? ThemeMode.dark : ThemeMode.light;

  Future<bool> getConfig() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      _langCode = prefs.getString('language') ?? 'EN';
      darkTheme = prefs.getBool('darkTheme') ?? false;

      isInit = true;
      await updateTheme(darkTheme);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeLanguage(String country, BuildContext context) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      _langCode = country;
      await prefs.setString('language', _langCode);
      await loadAppConfig(isSwitched: true);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> updateTheme(bool theme) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      darkTheme = theme;
      // Utils.changeStatusBarColor(themeMode);
      await prefs.setBool('darkTheme', theme);
      notifyListeners();
    } catch (error) {
      // print('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  void updateShowDemo(bool value) {
    showDemo = value;
    notifyListeners();
  }

  void updateUsername(String user) {
    username = user;
    notifyListeners();
  }

  Future<Map> loadAppConfig({bool isSwitched = false}) async {
    try {
      if (!isInit) {
        await getConfig();
      }
      final storage = LocalStorage('builder.json');
      var config = await storage.getItem('config');
      if (config != null) {
        appConfig = config;
      }

      /// Load Product ratio from config file

      drawer = appConfig['Drawer'] != null
          ? Map<String, dynamic>.from(appConfig['Drawer'])
          : {};

      /// Load categories config for the Tabbar menu
      /// User to sort the category Setting

      isLoading = false;
      notifyListeners();

      return appConfig;
    } catch (err, trace) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
      return {};
    }
  }
}

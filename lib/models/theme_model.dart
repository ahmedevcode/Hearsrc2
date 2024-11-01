import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { Dark, Light }

class ThemeModel extends ChangeNotifier {
  Color _tempPrimaryMainColor = Color(0xffb68a35);
  ColorSwatch? _tempAccentColor;
  ColorSwatch? _tempScaffoldColor;
  ColorSwatch? _tempTextColor;
  ColorSwatch? _tempAppbarColor;
  ColorSwatch? _tempDividerColor;
  Color _scaffoldColor = Colors.grey;
  Color? colorChoosenColor;
  String? _colorChoosed;
  static AppBarTheme? appBarTheme1;
  ColorSwatch _accentColor = Colors.orange;
  ColorSwatch _textColor = Colors.brown;
  Color? _currentColor;
  Color _pickerColor = Colors.red;
  Color? _primaryTempShadeColor;
  Color? _accentTempShadeColor;
  Color? _scaffoldTempShadeColor;
  Color? _textTempShadeColor;
  Color? _appbarTempShadeColor;
  Color? _dividerTempShadeColor;
  Color? _primaryShadeColor = Colors.cyan[800];
  Color _accentShadeColor = Colors.amber;
  Color? _appbarShadeColor = Colors.cyan[500];
  Color? _dividerShadeColor = Colors.grey[800];
  Color? _textShadeColor = Colors.blue[800];
  Color? _scaffoldShadeColor = Colors.blue[800];
  ThemeType _themeType = ThemeType.Light;
  double article_size = 12;
  bool notification = true;
  String? userId = null;
  Color _primaryMainColor = Colors.blue;
  ColorSwatch _appbarColor = Colors.blue;
  ColorSwatch _dividerColor = Colors.grey;

  //getters
  Color? get appbarTempShadeColor => _appbarTempShadeColor;
  Color? get textTempShadeColor => _textTempShadeColor;
  Color get scaffoldColor => _scaffoldColor;
  Color get accentShadeColor => _accentShadeColor;
  Color? get scaffoldTempShadeColor => _scaffoldTempShadeColor;
  ColorSwatch get appbarcolor => _appbarColor;
  Color? get scaffoldShadeColor => _scaffoldShadeColor;
  Color? get accentTempShadeColor => _accentTempShadeColor;
  ColorSwatch? get tempScaffoldColor => _tempScaffoldColor;
  Color? get primaryTempShadeColor => _primaryTempShadeColor;
  Color get tempPrimaryMainColor => _tempPrimaryMainColor;
  Color? get primaryShadeColor => _primaryShadeColor;
  ColorSwatch get accentColor => _accentColor;
  Color get primaryMainColor => _primaryMainColor;
  get pickerColor => _pickerColor;
  get currentColor => _currentColor;
  get colorChoosed => _colorChoosed;
  ColorSwatch? get tempDividerColor => _tempDividerColor;
  ColorSwatch? get tempAppbarColor => _tempAppbarColor;
  ColorSwatch get textColor => _textColor;
  double get articleSize => article_size;
  bool get _notification => notification;
  ColorSwatch? get tempAccentColor => _tempAccentColor;
  ColorSwatch? get dividerColor => _dividerColor;
  ColorSwatch? get tempTextColor => _tempTextColor;
  Color? get dividerShadeColor => _dividerShadeColor;
  Color? get appbarShadeColor => _appbarShadeColor;
  Color? get textShadeColor => _textShadeColor;
  Color? get dividerTempShadeColor => _dividerTempShadeColor;

  Locale _appLocale = const Locale('en');
  bool login = false;

  Locale get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode == null) {
      _appLocale = const Locale('en');
    } else {
      _appLocale = Locale(languageCode);
    }
  }

  Future<void> fetchArticleSize() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('font_size');

    if (fontSize == null) {
      article_size = 14;
    } else {
      article_size = fontSize;
    }
  }

  Future<void> fetchNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final notify = prefs.getBool('notify');

    if (notify == null) {
      notification = true;
    } else {
      notification = notify;
    }
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }

  void changeArticle(double size) async {
    var prefs = await SharedPreferences.getInstance();
    if (article_size == size) {
      return;
    }

    await prefs.setDouble('font_size', size);

    notifyListeners();
  }

  void changeNotify(bool noti) async {
    var prefs = await SharedPreferences.getInstance();
    if (notification == noti) {
      return;
    }

    await prefs.setBool('notify', noti);

    notifyListeners();
  }

  void checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    //await  prefs.setString('id', 'evzEPPen9ld7Bm1dn1EIMtrWgJC2');
    userId = await prefs.getString('id');
    var theme = await prefs.getInt('theme');
    var langs = await prefs.getString('language_code');
    var size = await prefs.getDouble('font_size');
    var noti = await prefs.getBool('notify');
    if (size != null) {
      article_size = size;
    }
    if (noti != null) {
      notification = noti;
    }
    langs != null ? _appLocale = Locale(langs) : _appLocale = Locale("en");
    theme != null ? _primaryMainColor = Color(theme) : null;

    if (userId != null) {
      login = true;
    } else
      login = false;
    notifyListeners();
  }

  //setters

  setDividerTempShadeColor(Color value) {
    _dividerTempShadeColor = value;
    notifyListeners();
  }

  setTextShadeColor(Color value) {
    _textShadeColor = value;
    notifyListeners();
  }

  setDividerShadeColor(Color value) {
    _dividerShadeColor = value;
    notifyListeners();
  }

  setAppbarShadeColor(Color value) {
    _appbarShadeColor = value;
    notifyListeners();
  }

  setAppbarTempShadeColor(Color value) {
    _appbarTempShadeColor = value;
    notifyListeners();
  }

  setTextTempShadeColor(Color value) {
    _textTempShadeColor = value;
    notifyListeners();
  }

  setDividerColor(ColorSwatch value) {
    _dividerColor = value;
    notifyListeners();
  }

  setTextColor(ColorSwatch value) {
    _textColor = value;
    notifyListeners();
  }

  setTempAccentColor(ColorSwatch value) {
    _tempAccentColor = value;
    notifyListeners();
  }

  setTempTextColor(ColorSwatch value) {
    _tempTextColor = value;
    notifyListeners();
  }

  setTempAppbarColor(ColorSwatch value) {
    _tempAppbarColor = value;
    //print('setTempAppbarColor');
    notifyListeners();
  }

  setTempDividerColor(ColorSwatch value) {
    _tempDividerColor = value;
    notifyListeners();
  }

  setScaffoldShadeColor(Color value) {
    _scaffoldShadeColor = value;
    notifyListeners();
  }

  setTempScaffoldColor(ColorSwatch value) {
    _tempScaffoldColor = value;
    notifyListeners();
  }

  setAccentTempShadeColor(Color value) {
    _accentTempShadeColor = value;
    notifyListeners();
  }

  setTempShadeColor(Color value) {
    _primaryTempShadeColor = value;
    notifyListeners();
  }

  setPrimaryShadeColor(Color value) {
    _primaryShadeColor = value;
    notifyListeners();
  }

  setTempPrimaryMainColor(Color value) {
    _tempPrimaryMainColor = value;
    notifyListeners();
  }

  setAccentColor(ColorSwatch value) {
    _accentColor = value;
    notifyListeners();
  }

  setPrimaryMainColor(Color value) async {
    _primaryMainColor = value;
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme', value.value);
    notifyListeners();
  }

  set currentColor(value) {
    _currentColor = value;
    notifyListeners();
  }

  set colorChoosed(value) {
    _colorChoosed = value;
    notifyListeners();
  }

  set pickerColor(value) {
    _pickerColor = value;
    notifyListeners();
  }

  setScaffoldTempShadeColor(Color value) {
    _scaffoldTempShadeColor = value;
    notifyListeners();
  }

  setAccentShadeColor(Color value) {
    _accentShadeColor = value;
    notifyListeners();
  }

  setScaffoldColor(ColorSwatch value) {
    _scaffoldColor = value;
    notifyListeners();
  }

  setAppbarColor(ColorSwatch value) {
    _appbarColor = value;
    notifyListeners();
  }
/*
const kThemeGoldBackground = Color(0XFFAD8339);
const kThemeGoldText = Colors.white;
const kThemeGoldHighlight = Color(0XFFFFD700);

//const list for Blue Theme
const kThemeBlueBackground = Color(0XFFE4572E);
const KThemeBlueText = Colors.white;
const kThemeBlueHighlight = Color(0XFFFFD700);

//const list for Orange Theme
const kThemeOrangeBackground = Color(0XFFcc8b80);
const kThemeOrangeText = Colors.black;
const kThemeOrangeHighlight = Color(0XFF29335C);

//const list for Dark Theme
const KThemeDarkBackground = Colors.black;
const kThemeDarkText = Colors.white;
const kThemeDarkHighlight = Colors.amber;
 */
//
//
//  colorChoosen(String value) {
//    if (value.contains("red")) {
//      colorChoosed = "red";
//      colorChoosenColor = Colors.red;
//    } else if (value.contains("blue")) {
//      colorChoosed = "blue";
//      colorChoosenColor = Colors.blue;
//    }
//    notifyListeners();
//  }
//
//  AppBarTheme currentAppBarTheme = appBarTheme1;
//
//  void toggleTheme() {
//    if (_themeType == ThemeType.Light) {
//      currentTheme = darkTheme;
//      _themeType = ThemeType.Dark;
//    } else if (_themeType == ThemeType.Dark) {
//      currentTheme = lightTheme;
//      _themeType = ThemeType.Light;
//    }
//
//    notifyListeners();
//  }
//
//  AppBarTheme changeAppBarColor(Color color, Color iconThemecolor) {
//    appBarTheme1 = AppBarTheme(
//        color: color, actionsIconTheme: IconThemeData(color: iconThemecolor));
//  }
//
//  void appBarTheme(String color) {
//    if (color.contains("red")) {
//      changeAppBarColor(Colors.red, Colors.red);
//      currentAppBarTheme = appBarTheme1;
//    } else if (color.contains("green")) {
//      changeAppBarColor(Colors.green, Colors.green);
//      currentAppBarTheme = appBarTheme1;
//    } else if (color.contains("blue")) {
//      changeAppBarColor(Colors.blue, Colors.blue);
//      currentAppBarTheme = appBarTheme1;
//    }
//    notifyListeners();
//  }
}

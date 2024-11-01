import 'dart:io';
import 'package:flutter/services.dart';

class GmsTools {
  /// Replace 'com.inspireui.check' with your package name.
  /// Also replace in MainActivity.kt.
  static const _packageName = 'com.hearme';

  /// DO NOT CHANGE THESE TWO LINES BELOW.
  static const _isGmsAvailableMethod = 'isGmsAvailable';
  static const _gmsCheckMethodChannel = '$_packageName/$_isGmsAvailableMethod';

  static final GmsTools _instance = GmsTools._internal();

  factory GmsTools() => _instance;

  GmsTools._internal();

  bool _isGmsAvailable = false; // Initialize with a default value

  bool get isGmsAvailable {
    return _isGmsAvailable;
  }

  /// Just need to call this once when app initialize.
  /// Then use GmsTools().isGmsAvailable getter instead.
  Future<bool> checkGmsAvailability() async {
    if (Platform.isAndroid) {
      try {
        var status = await (const MethodChannel(_gmsCheckMethodChannel))
            .invokeMethod(_isGmsAvailableMethod);
        _isGmsAvailable = status;
      } on PlatformException {
        // Handle exception
        _isGmsAvailable = false; // Fallback value
      }
    } else {
      /// Just need to check for Android.
      /// Default true for other OS.
      _isGmsAvailable = true;
    }
    return _isGmsAvailable;
  }
}

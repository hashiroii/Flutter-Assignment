import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this.dark,
    required this.city,
    required this.avatarPath,
  });

  final SharedPreferencesAsync _prefs;

  bool dark;
  String? city;
  String? avatarPath;

  Future<void> setDark(bool v) async {
    dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  Future<void> setAvatar(String path) async {
    avatarPath = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _lastEmailKey = 'last_email';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // For testing purposes
  static void reset() {
    _instance._prefs = null;
  }

  // Save the last successfully logged in email
  Future<void> saveLastEmail(String email) async {
    await init();
    await _prefs!.setString(_lastEmailKey, email);
  }

  // Get the last successfully logged in email
  Future<String?> getLastEmail() async {
    await init();
    return _prefs!.getString(_lastEmailKey);
  }

  // Save notification preference
  Future<void> saveNotificationPreference(bool isEnabled) async {
    await init();
    await _prefs!.setBool(_notificationsEnabledKey, isEnabled);
  }

  // Get notification preference (defaults to true)
  Future<bool> getNotificationPreference() async {
    await init();
    return _prefs!.getBool(_notificationsEnabledKey) ?? true;
  }
}

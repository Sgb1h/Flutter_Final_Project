import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _firstNameKey = 'first_name';
  static const String _lastNameKey = 'last_name';
  static const String _addressKey = 'address';
  static const String _birthdayKey = 'birthday';

  Future<void> saveCustomerData({
    required String firstName,
    required String lastName,
    required String address,
    required String birthday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
    await prefs.setString(_addressKey, address);
    await prefs.setString(_birthdayKey, birthday);
  }

  Future<Map<String, dynamic>> loadCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _firstNameKey: prefs.getString(_firstNameKey) ?? '',
      _lastNameKey: prefs.getString(_lastNameKey) ?? '',
      _addressKey: prefs.getString(_addressKey) ?? '',
      _birthdayKey: prefs.getString(_birthdayKey) ?? '',
    };
  }
}

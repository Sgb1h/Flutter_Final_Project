import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferencesHelper {
  static const String _typeKey = 'airplane_type';
  static const String _passengersKey = 'number_of_passengers';
  static const String _speedKey = 'max_speed';
  static const String _rangeKey = 'range';

  final storage = FlutterSecureStorage();

  Future<void> saveAirplaneData({
    required String type,
    required int passengers,
    required int speed,
    required int range,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, type);
    await prefs.setInt(_passengersKey, passengers);
    await prefs.setInt(_speedKey, speed);
    await prefs.setInt(_rangeKey, range);
  }

  Future<Map<String, dynamic>> loadAirplaneData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _typeKey: prefs.getString(_typeKey) ?? '',
      _passengersKey: prefs.getInt(_passengersKey) ?? 0,
      _speedKey: prefs.getInt(_speedKey) ?? 0,
      _rangeKey: prefs.getInt(_rangeKey) ?? 0,
    };
  }
}

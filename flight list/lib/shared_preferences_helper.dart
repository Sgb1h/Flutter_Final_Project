import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _departureCityKey = 'departure_city';
  static const String _destinationCityKey = 'destination_city';
  static const String _departureTimeKey = 'departure_time';
  static const String _arrivalTimeKey = 'arrival_time';

  Future<void> saveFlightData({
    required String departureCity,
    required String destinationCity,
    required String departureTime,
    required String arrivalTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_departureCityKey, departureCity);
    await prefs.setString(_destinationCityKey, destinationCity);
    await prefs.setString(_departureTimeKey, departureTime);
    await prefs.setString(_arrivalTimeKey, arrivalTime);
  }

  Future<Map<String, dynamic>> loadFlightData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _departureCityKey: prefs.getString(_departureCityKey) ?? '',
      _destinationCityKey: prefs.getString(_destinationCityKey) ?? '',
      _departureTimeKey: prefs.getString(_departureTimeKey) ?? '',
      _arrivalTimeKey: prefs.getString(_arrivalTimeKey) ?? '',
    };
  }
}

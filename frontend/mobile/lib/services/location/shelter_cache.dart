import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/navigation_model.dart';

class ShelterCache {
  static const String _key = 'cached_nearest_shelters';

  Future<void> saveShelters(List<NearestShelterRouteModel> shelters) async {
    final prefs = await SharedPreferences.getInstance();
    final data = shelters.map((s) => s.toJson()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<List<NearestShelterRouteModel>> getShelters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> data = jsonDecode(jsonString);
    return data
        .map(
          (item) =>
              NearestShelterRouteModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> clearShelters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

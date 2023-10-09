import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferenceLocalDataSourceProvider = Provider((ref) {
  return PreferenceLocalDataStore();
});

enum PreferenceKey { profile }

class PreferenceLocalDataStore {
  Future<void> save(PreferenceKey key, String value) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setString(key.name, value);
  }
}

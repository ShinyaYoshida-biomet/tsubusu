import 'package:shared_preferences/shared_preferences.dart';

class WindowCounterService {
  static const String _counterKey = 'window_counter';
  
  static Future<int> getNextWindowNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCounter = prefs.getInt(_counterKey) ?? 0;
    final nextCounter = currentCounter + 1;
    await prefs.setInt(_counterKey, nextCounter);
    return nextCounter;
  }
}
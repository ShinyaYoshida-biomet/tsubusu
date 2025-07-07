import 'package:shared_preferences/shared_preferences.dart';
import '../models/animation_type.dart';

class PreferencesService {
  static const String _animationTypeKey = 'animation_type';

  static Future<AnimationType> getAnimationType() async {
    final prefs = await SharedPreferences.getInstance();
    final animationTypeIndex = prefs.getInt(_animationTypeKey) ?? 0;
    return AnimationType.values[animationTypeIndex];
  }

  static Future<void> setAnimationType(AnimationType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_animationTypeKey, type.index);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// 全局本地存储服务
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Buvid
  String? get buvid => _prefs.getString(AppConstants.keyBuvid);
  Future<bool> setBuvid(String val) =>
      _prefs.setString(AppConstants.keyBuvid, val);

  // Wbi ImgKey / SubKey
  String? get wbiImgKey => _prefs.getString(AppConstants.keyWbiImgKey);
  String? get wbiSubKey => _prefs.getString(AppConstants.keyWbiSubKey);

  Future<void> saveWbiKeys(String imgKey, String subKey) async {
    await _prefs.setString(AppConstants.keyWbiImgKey, imgKey);
    await _prefs.setString(AppConstants.keyWbiSubKey, subKey);
  }

  // 用户偏好画质 (默认 120 为 4K/自动最高，无缝记住用户选择)
  int get preferredQuality => _prefs.getInt('key_preferred_qn') ?? 120;
  Future<bool> setPreferredQuality(int qn) =>
      _prefs.setInt('key_preferred_qn', qn);

  // 设备 HDR 输出能力开关 (默认 false 置灰，避免非 HDR 显示器画面发灰发暗)
  bool get isHdrEnabled => _prefs.getBool('key_enable_hdr') ?? false;
  Future<bool> setHdrEnabled(bool val) =>
      _prefs.setBool('key_enable_hdr', val);

  // 通用读写
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String val) => _prefs.setString(key, val);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool val) => _prefs.setBool(key, val);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}

/// Riverpod Provider，在 main.dart 中通过 overrideWithValue 注入初始化完成的实例
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized in main()');
});


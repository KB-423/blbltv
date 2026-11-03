import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Bilibili Wbi 签名生成器
/// 参考文档: https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md
class WbiSigner {
  WbiSigner._();

  static const List<int> _mixinKeyEncTab = <int>[
    46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
    33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40,
    61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11,
    36, 20, 34, 44, 52,
  ];

  /// 对 imgKey 和 subKey 进行字符顺序重排打乱
  static String getMixinKey(String rawKey) {
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < _mixinKeyEncTab.length; i++) {
      if (_mixinKeyEncTab[i] < rawKey.length) {
        sb.write(rawKey[_mixinKeyEncTab[i]]);
      }
    }
    final String res = sb.toString();
    return res.length > 32 ? res.substring(0, 32) : res;
  }

  /// 为请求参数生成带有 wts 和 w_rid 的签名 Map
  static Map<String, dynamic> sign({
    required Map<String, dynamic> params,
    required String imgKey,
    required String subKey,
  }) {
    final String mixinKey = getMixinKey(imgKey + subKey);
    final int currTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final RegExp chrFilter = RegExp(r"[!\'\(\)*]");

    final Map<String, dynamic> signedParams = Map<String, dynamic>.from(params)
      ..['wts'] = currTime;

    // 参数字典排序
    final List<String> sortedKeys = signedParams.keys.toList()..sort();
    final List<String> queryPairs = [];

    for (final String key in sortedKeys) {
      final dynamic value = signedParams[key];
      if (value == null) continue;
      final String encodedKey = Uri.encodeComponent(key);
      final String encodedVal = Uri.encodeComponent(value.toString())
          .replaceAllMapped(chrFilter, (_) => '');
      queryPairs.add('$encodedKey=$encodedVal');
    }

    final String queryStr = queryPairs.join('&');
    final String wbiSign =
        md5.convert(utf8.encode(queryStr + mixinKey)).toString();

    signedParams['w_rid'] = wbiSign;
    return signedParams;
  }
}


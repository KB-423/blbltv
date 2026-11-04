import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';
import '../utils/wbi_signer.dart';

/// 统一网络请求客户端
class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;
  PersistCookieJar? _cookieJar;

  ApiClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.webBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Referer': ApiConstants.defaultReferer,
          'User-Agent': ApiConstants.defaultUserAgent,
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  Future<void> initCookieJar() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String cookiePath = '${appDocDir.path}/bili_tv_cookies';
      _cookieJar = PersistCookieJar(
        storage: FileStorage(cookiePath),
        ignoreExpires: true,
      );
    } catch (e) {
      debugPrint('[ApiClient] CookieJar 初始化异常: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 注入 Cookie
          if (_cookieJar != null) {
            final uri = options.uri;
            final cookies = await _cookieJar!.loadForRequest(uri);
            if (cookies.isNotEmpty) {
              options.headers['cookie'] =
                  cookies.map((c) => '${c.name}=${c.value}').join('; ');
            }
          }

          // 注入 Buvid 如果存在
          final buvid = _storageService.buvid;
          if (buvid != null && buvid.isNotEmpty) {
            options.headers['buvid3'] = buvid;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // 保存 Cookie
          if (_cookieJar != null && response.headers.map['set-cookie'] != null) {
            final uri = response.requestOptions.uri;
            final setCookies = response.headers.map['set-cookie']!;
            final cookies = setCookies
                .map((str) => Cookie.fromSetCookieValue(str))
                .toList();
            await _cookieJar!.saveFromResponse(uri, cookies);
          }
          return handler.next(response);
        },
        onError: (DioException err, handler) {
          debugPrint('[ApiClient Error] ${err.requestOptions.uri} -> ${err.message}');
          return handler.next(err);
        },
      ),
    );
  }

  /// 检查并获取 Wbi 签名所需的 imgKey 与 subKey
  Future<void> ensureWbiKeys() async {
    final imgKey = _storageService.wbiImgKey;
    final subKey = _storageService.wbiSubKey;
    if (imgKey != null && imgKey.isNotEmpty && subKey != null && subKey.isNotEmpty) {
      return;
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiConstants.navUserInfo);
      final data = res.data;
      if (data != null && data['data'] != null && data['data']['wbi_img'] != null) {
        final wbiImg = data['data']['wbi_img'];
        final String imgUrl = wbiImg['img_url'] ?? '';
        final String subUrl = wbiImg['sub_url'] ?? '';

        if (imgUrl.isNotEmpty && subUrl.isNotEmpty) {
          final String extractedImgKey =
              imgUrl.substring(imgUrl.lastIndexOf('/') + 1).split('.')[0];
          final String extractedSubKey =
              subUrl.substring(subUrl.lastIndexOf('/') + 1).split('.')[0];
          await _storageService.saveWbiKeys(extractedImgKey, extractedSubKey);
        }
      }
    } catch (e) {
      debugPrint('[ApiClient] 获取 Wbi 密钥失败: $e');
    }
  }

  /// 带有 Wbi 签名的 GET 请求
  Future<Response<T>> getWbi<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await ensureWbiKeys();

    final imgKey = _storageService.wbiImgKey ?? '';
    final subKey = _storageService.wbiSubKey ?? '';

    Map<String, dynamic> params = queryParameters ?? {};
    if (imgKey.isNotEmpty && subKey.isNotEmpty) {
      params = WbiSigner.sign(
        params: params,
        imgKey: imgKey,
        subKey: subKey,
      );
    }

    return _dio.get<T>(
      path,
      queryParameters: params,
      options: options,
    );
  }

  /// 普通 GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// 普通 POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Riverpod Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

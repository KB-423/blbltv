import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/user/user_bangumi_model.dart';
import '../../../../models/user/user_favorite_model.dart';
import '../../../../models/user/user_history_model.dart';
import '../../../../models/user/user_info_model.dart';

/// 用户与个人中心数据仓库
class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  /// 申请 TV 扫码登录二维码
  Future<({String url, String qrcodeKey})> getQrCode() async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.qrcodeGenerate,
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final qData = data['data'];
        return (
          url: qData['url'] as String? ?? '',
          qrcodeKey: qData['qrcode_key'] as String? ?? '',
        );
      }
      throw Exception(data?['message'] ?? '生成二维码失败');
    } catch (e) {
      debugPrint('[UserRepository] 生成登录二维码失败: $e');
      rethrow;
    }
  }

  /// 轮询扫码状态
  /// code 说明：
  /// - 0: 登录成功
  /// - 86101: 未扫码
  /// - 86090: 已扫码未确认
  /// - 86038: 二维码已失效
  Future<({int code, String message, String url})> pollQrCode(
    String qrcodeKey,
  ) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.qrcodePoll,
        queryParameters: {'qrcode_key': qrcodeKey},
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final pollData = data['data'];
        final pollCode = pollData['code'] as int? ?? -1;
        final pollMsg = pollData['message'] as String? ?? '';
        final pollUrl = pollData['url'] as String? ?? '';

        return (code: pollCode, message: pollMsg, url: pollUrl);
      }
      throw Exception(data?['message'] ?? '轮询扫码状态失败');
    } catch (e) {
      debugPrint('[UserRepository] 轮询扫码异常: $e');
      rethrow;
    }
  }

  /// 获取当前登录用户信息（基于保存的 Cookie 会话）
  Future<UserInfoModel?> fetchUserInfo() async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.navUserInfo,
      );

      final data = res.data;
      if (data != null && data['data'] != null) {
        final uData = data['data'] as Map<String, dynamic>;
        final isLogin = uData['isLogin'] as bool? ?? false;
        if (isLogin) {
          return UserInfoModel.fromJson(uData);
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('[UserRepository] 获取用户信息失败: $e');
      rethrow;
    }
  }

  /// 获取用户播放历史记录
  Future<List<UserHistoryItem>> fetchHistory({
    int max = 0,
    int viewAt = 0,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.historyList,
        queryParameters: {
          'type': 'all',
          'ps': 24,
          if (max > 0) 'max': max,
          if (viewAt > 0) 'view_at': viewAt,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => UserHistoryItem.fromJson(e))
            .where((item) => item.bvid.isNotEmpty)
            .toList();
      }

      if (data?['code'] == -101) {
        throw Exception('未登录，请先扫码登录后查看历史记录');
      }

      throw Exception(data?['message'] ?? '获取历史记录失败');
    } catch (e) {
      debugPrint('[UserRepository] 获取历史记录失败: $e');
      rethrow;
    }
  }

  /// 获取用户创建的收藏夹列表
  Future<List<UserFavFolder>> fetchFavFolders(int mid) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.userFavFolders,
        queryParameters: {'up_mid': mid},
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => UserFavFolder.fromJson(e))
            .toList();
      }

      throw Exception(data?['message'] ?? '获取收藏夹列表失败');
    } catch (e) {
      debugPrint('[UserRepository] 获取收藏夹列表失败: $e');
      rethrow;
    }
  }

  /// 获取指定收藏夹内的视频资源列表
  Future<List<UserFavItem>> fetchFavResources({
    required int mediaId,
    int pn = 1,
    int ps = 20,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.userFavResources,
        queryParameters: {
          'media_id': mediaId,
          'pn': pn,
          'ps': ps,
          'order': 'mtime',
          'type': 0,
          'platform': 'web',
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final medias = data['data']['medias'] as List<dynamic>? ?? [];
        return medias
            .whereType<Map<String, dynamic>>()
            .map((e) => UserFavItem.fromJson(e))
            .where((item) => item.bvid.isNotEmpty)
            .toList();
      }

      throw Exception(data?['message'] ?? '获取收藏视频失败');
    } catch (e) {
      debugPrint('[UserRepository] 获取收藏视频失败: $e');
      rethrow;
    }
  }

  /// 获取用户追番/追剧列表 (type: 1 番剧, 2 影视/电视剧)
  Future<List<UserBangumiItem>> fetchBangumiFollow({
    required int mid,
    int type = 1,
    int pn = 1,
    int ps = 20,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bangumiFollow,
        queryParameters: {
          'vmid': mid,
          'type': type,
          'follow_status': 0,
          'pn': pn,
          'ps': ps,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => UserBangumiItem.fromJson(e))
            .toList();
      }

      throw Exception(data?['message'] ?? '获取追番列表失败');
    } catch (e) {
      debugPrint('[UserRepository] 获取追番列表失败: $e');
      rethrow;
    }
  }

  /// 退出登录：清空会话与 Cookie
  Future<void> logout() async {
    await _apiClient.clearCookies();
  }
}

/// Riverpod Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return UserRepository(client);
});

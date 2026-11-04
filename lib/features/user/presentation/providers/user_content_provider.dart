import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user/user_bangumi_model.dart';
import '../../../../models/user/user_favorite_model.dart';
import '../../../../models/user/user_history_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

/// 用户历史记录 Provider
final userHistoryProvider =
    FutureProvider.autoDispose<List<UserHistoryItem>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isLoggedIn) {
    return const [];
  }
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchHistory();
});

/// 用户收藏夹列表 Provider
final userFavFoldersProvider =
    FutureProvider.autoDispose<List<UserFavFolder>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isLoggedIn || authState.user == null) {
    return const [];
  }
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchFavFolders(authState.user!.mid);
});

/// 指定收藏夹内容 Provider
final userFavResourcesProvider = FutureProvider.autoDispose
    .family<List<UserFavItem>, int>((ref, mediaId) async {
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchFavResources(mediaId: mediaId);
});

/// 用户追番列表 Provider (type 1: 番剧)
final userBangumiProvider =
    FutureProvider.autoDispose<List<UserBangumiItem>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isLoggedIn || authState.user == null) {
    return const [];
  }
  final repo = ref.read(userRepositoryProvider);
  return repo.fetchBangumiFollow(mid: authState.user!.mid, type: 1);
});

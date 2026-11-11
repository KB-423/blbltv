import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/video/video_item_model.dart';
import '../../data/models/channel_item_model.dart';
import '../../data/repositories/channel_repository.dart';

/// 频道板块状态
class ChannelState {
  final int selectedMainIndex;
  final int selectedSubIndex;
  final AsyncValue<List<VideoItemModel>> videos;

  const ChannelState({
    this.selectedMainIndex = 0,
    this.selectedSubIndex = 0,
    this.videos = const AsyncValue.loading(),
  });

  MainChannel get currentMainChannel =>
      MainChannel.defaultChannels[selectedMainIndex];

  SubChannel get currentSubChannel =>
      currentMainChannel.subChannels[selectedSubIndex];

  int get currentRid => currentSubChannel.rid;

  ChannelState copyWith({
    int? selectedMainIndex,
    int? selectedSubIndex,
    AsyncValue<List<VideoItemModel>>? videos,
  }) {
    return ChannelState(
      selectedMainIndex: selectedMainIndex ?? this.selectedMainIndex,
      selectedSubIndex: selectedSubIndex ?? this.selectedSubIndex,
      videos: videos ?? this.videos,
    );
  }
}

class ChannelNotifier extends Notifier<ChannelState> {
  late final ChannelRepository _repository;
  int _requestId = 0;

  @override
  ChannelState build() {
    _repository = ref.read(channelRepositoryProvider);
    Future.microtask(() => _fetchVideos(MainChannel.defaultChannels[0].subChannels[0].rid));
    return const ChannelState();
  }

  Future<void> selectMainChannel(int mainIndex) async {
    if (mainIndex < 0 || mainIndex >= MainChannel.defaultChannels.length) return;
    if (state.selectedMainIndex == mainIndex) return;

    state = state.copyWith(
      selectedMainIndex: mainIndex,
      selectedSubIndex: 0,
      videos: const AsyncValue.loading(),
    );

    final subChannel = MainChannel.defaultChannels[mainIndex].subChannels[0];
    await _fetchVideos(subChannel.rid);
  }

  Future<void> selectSubChannel(int subIndex) async {
    final subChannels = state.currentMainChannel.subChannels;
    if (subIndex < 0 || subIndex >= subChannels.length) return;
    if (state.selectedSubIndex == subIndex && state.videos.hasValue) return;

    state = state.copyWith(
      selectedSubIndex: subIndex,
      videos: const AsyncValue.loading(),
    );

    final subChannel = subChannels[subIndex];
    await _fetchVideos(subChannel.rid);
  }

  Future<void> refresh() async {
    state = state.copyWith(videos: const AsyncValue.loading());
    await _fetchVideos(state.currentRid);
  }

  Future<void> _fetchVideos(int rid) async {
    final curReq = ++_requestId;
    try {
      final list = await _repository.fetchChannelVideos(rid: rid);
      if (curReq == _requestId && ref.mounted) {
        state = state.copyWith(videos: AsyncValue.data(list));
      }
    } catch (e, st) {
      if (curReq == _requestId && ref.mounted) {
        state = state.copyWith(videos: AsyncValue.error(e, st));
      }
    }
  }
}

final channelProvider =
    NotifierProvider<ChannelNotifier, ChannelState>(ChannelNotifier.new);

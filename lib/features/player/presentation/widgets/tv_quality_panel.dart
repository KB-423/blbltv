import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../user/presentation/providers/auth_provider.dart';

/// TV 遥控器大屏画质选择面板
/// 支持：
/// - 记住用户手动选择的最高画质偏好
/// - 识别未登录 / 需大会员画质权限并置灰提示
/// - 识别设备 HDR / 杜比视界支持能力，不支持则置灰提示
class TvQualityPanel extends ConsumerStatefulWidget {
  final List<VideoQualityItem> qualities;
  final int currentQn;
  final ValueChanged<int> onSelectQuality;
  final VoidCallback onClose;

  const TvQualityPanel({
    super.key,
    required this.qualities,
    required this.currentQn,
    required this.onSelectQuality,
    required this.onClose,
  });

  @override
  ConsumerState<TvQualityPanel> createState() => _TvQualityPanelState();
}

class _TvQualityPanelState extends ConsumerState<TvQualityPanel> {
  String? _hintMessage;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _showNotice(String msg) {
    _hintTimer?.cancel();
    setState(() {
      _hintMessage = msg;
    });
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _hintMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storage = ref.watch(storageServiceProvider);

    final bool isLoggedIn = authState.isLoggedIn && authState.user != null;
    final bool isVip = authState.user?.vipStatus == 1;
    final bool isHdrEnabled = storage.isHdrEnabled;

    return Container(
      width: 360,
      height: double.infinity,
      color: TvTheme.tvSurface.withValues(alpha: 0.96),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 面板标题与关闭按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '画质选择',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DpadFocusable(
                onSelect: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TvTheme.tvSurfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '使用遥控器上下键选择，按确定键切换',
            style: TextStyle(
              color: TvTheme.tvTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // 权限 / 设备不可用提示横幅
          if (_hintMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hintMessage!,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 画质列表
          Expanded(
            child: DpadRegion(
              child: ListView.separated(
                itemCount: widget.qualities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = widget.qualities[index];
                  final isCurrent = item.qn == widget.currentQn;

                  // 1. 设备 HDR / 杜比视界支持判断
                  final bool isHdrItem = item.qn == 125 || item.qn == 126;
                  final bool isDeviceSupported = !isHdrItem || isHdrEnabled;

                  // 2. 账号登录与大会员权限判断
                  bool isAuthPermitted = true;
                  String lockBadge = '';
                  String lockReason = '';

                  if (!isDeviceSupported) {
                    lockBadge = '设备不支持';
                    lockReason = '当前设备或系统未开启 HDR 输出支持';
                  } else if (!isLoggedIn && item.qn >= 80) {
                    isAuthPermitted = false;
                    lockBadge = '需登录';
                    lockReason = '1080P 及以上画质需登录后使用，请前往【我的】扫码登录';
                  } else if (isLoggedIn && !isVip && item.qn > 80) {
                    isAuthPermitted = false;
                    lockBadge = '大会员';
                    lockReason = '1080P高码率及以上超清画质为哔哩哔哩大会员专享';
                  }

                  final bool isAvailable = isDeviceSupported && isAuthPermitted;

                  return DpadFocusable(
                    autofocus: isCurrent,
                    onSelect: () {
                      if (!isAvailable) {
                        _showNotice(lockReason);
                      } else {
                        widget.onSelectQuality(item.qn);
                      }
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isAvailable ? 1.0 : 0.45,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? TvTheme.biliPink.withValues(alpha: 0.22)
                              : TvTheme.tvSurfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent
                                ? TvTheme.biliPink
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              !isAvailable
                                  ? (isHdrItem && !isDeviceSupported
                                      ? Icons.tv_off_rounded
                                      : Icons.lock_outline_rounded)
                                  : (isCurrent
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded),
                              size: 18,
                              color: !isAvailable
                                  ? TvTheme.tvTextDisabled
                                  : (isCurrent
                                      ? TvTheme.biliPink
                                      : TvTheme.tvTextDisabled),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.desc,
                                style: TextStyle(
                                  color: !isAvailable
                                      ? TvTheme.tvTextDisabled
                                      : (isCurrent
                                          ? Colors.white
                                          : TvTheme.tvTextPrimary),
                                  fontSize: 15,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: TvTheme.biliPink,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '当前',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else if (!isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDeviceSupported
                                      ? (item.qn > 80 && isLoggedIn
                                          ? const Color(0xFFF1659C)
                                          : Colors.amber.shade800)
                                      : Colors.grey.shade700,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  lockBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

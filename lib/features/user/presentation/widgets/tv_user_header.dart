import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../models/user/user_info_model.dart';
import '../../../../widgets/tv_image.dart';
import '../providers/auth_provider.dart';

/// TV 个人中心顶部用户信息栏
class TvUserHeader extends ConsumerWidget {
  final UserInfoModel user;

  const TvUserHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVip = user.vipStatus == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: TvTheme.tvSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TvTheme.tvDivider),
      ),
      child: Row(
        children: [
          // 用户头像
          ClipOval(
            child: SizedBox(
              width: 58,
              height: 58,
              child: user.face.isNotEmpty
                  ? TvImage(
                      imageUrl: user.face,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: TvTheme.tvSurfaceLight,
                      child: const Icon(
                        Icons.person_rounded,
                        color: TvTheme.tvTextSecondary,
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 18),

          // 昵称与等级/VIP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      user.uname.isNotEmpty ? user.uname : '哔哩哔哩用户',
                      style: const TextStyle(
                        color: TvTheme.tvTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 等级标
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LV${user.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (isVip) ...[
                      const SizedBox(width: 8),
                      // VIP 徽章
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TvTheme.biliPink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.vipLabelText.isNotEmpty
                              ? user.vipLabelText
                              : '大会员',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'UID: ${user.mid}',
                      style: const TextStyle(
                        color: TvTheme.tvTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '硬币: ${user.money.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: TvTheme.tvTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 退出登录按钮
          DpadFocusable(
            onSelect: () => _confirmLogout(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: TvTheme.tvSurfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: TvTheme.tvTextSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '退出登录',
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TvTheme.tvSurface,
        title: const Text('退出登录', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要退出当前哔哩哔哩账号登录吗？退出后将切回游客模式。',
          style: TextStyle(color: TvTheme.tvTextSecondary),
        ),
        actions: [
          DpadFocusable(
            autofocus: true,
            onSelect: () => Navigator.of(ctx).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: TvTheme.tvSurfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('取消', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          DpadFocusable(
            onSelect: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('确认退出', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

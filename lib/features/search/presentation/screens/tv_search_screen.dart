import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 搜索界面骨架
class TvSearchScreen extends StatelessWidget {
  const TvSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TvScaffold(
      header: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: TvTheme.biliBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '搜索视频与 UP 主',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '遥控器拼音/首字母检索',
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: TvTheme.tvSurfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '输入简拼搜索，例如: DBB (哔哩哔哩)',
                      style: TextStyle(
                        color: TvTheme.tvTextDisabled,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
                        .map(
                          (char) => DpadFocusable(
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: TvTheme.tvSurfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                char,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: TvTheme.tvTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '热搜榜',
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('1. 黑神话悟空', style: TextStyle(color: TvTheme.tvTextPrimary, fontSize: 15)),
                  SizedBox(height: 10),
                  Text('2. 2026 新番导视', style: TextStyle(color: TvTheme.tvTextPrimary, fontSize: 15)),
                  SizedBox(height: 10),
                  Text('3. 4K 演示片', style: TextStyle(color: TvTheme.tvTextPrimary, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
